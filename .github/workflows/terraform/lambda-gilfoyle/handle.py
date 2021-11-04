import base64
import boto3
from botocore.config import Config
from urllib import parse as urlparse
import requests
import json

boto_config = Config(
    region_name='us-east-1',
    signature_version='v4',
    retries={
        'max_attempts': 10,
        'mode': 'standard'
    }
)

dynamodb = boto3.client('dynamodb', config=boto_config)
table = "GlobalStore"
iterator_key = "gilfoyle#iterator"


def get_slack_url():
    return get_value('S', "gilfoyle#slack")


def get_value(key_type, key_value):
    i = dynamodb.get_item(
        TableName=table,
        Key={
            'k': {
                key_type: key_value
            }
        }
    )

    if "Item" in i and "v" in i["Item"]:
        return i["Item"]["v"][key_type]
    return None


def get_message(index):
    return get_value("S", "gilfoyle#messages#%s" % index)


def get_iterator():
    i = dynamodb.get_item(
        TableName=table,
        Key={
            'k': {
                'S': iterator_key
            }
        }
    )

    if "Item" in i:
        return int(i["Item"]["v"]["N"])
    else:
        print("Need to create the iterator, it disappeared.")
        return 1


def reset_iterator():
    dynamodb.update_item(
        TableName=table,
        Key={
            'k': {
                'S': iterator_key
            }
        },
        UpdateExpression="SET v = :val",
        ExpressionAttributeValues={
            ':val': {
                'N': "0"
            }
        }
    )


def increment_iterator():
    dynamodb.update_item(
        TableName=table,
        Key={
            'k': {
                'S': iterator_key
            }
        },
        UpdateExpression="SET v = v + :val",
        ExpressionAttributeValues={
            ':val': {
                'N': "1"
            }
        }
    )


def handle(event, context):
    body = dict(urlparse.parse_qsl(base64.b64decode(str(event['body'])).decode('ascii')))

    webhook_url = get_slack_url()
    if webhook_url is None:
        raise "Missing webhook URL"

    channel = "#%s" % body["channel_name"]

    i = get_iterator()

    if i > 39:
        reset_iterator()
    else:
        increment_iterator()

    text = get_message(i)

    message = {
        "text": text,
        "channel": channel
    }

    response = requests.post(
        webhook_url, json=message,
        headers={'Content-Type': 'application/json'}
    )

    if response.status_code != 200:
        raise ValueError(
            'Request to slack returned an error %s, the response is:\n%s'
            % (response.status_code, response.text)
        )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": ""
    }
