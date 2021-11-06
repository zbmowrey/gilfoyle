import base64
import boto3
from botocore.config import Config
import json
import random
import requests
from urllib import parse as urlparse

# Configure Boto3 clients for Dynamo and SSM Parameter Store

boto_config = Config(
    region_name='us-east-1',
    signature_version='v4',
    retries={
        'max_attempts': 10,
        'mode': 'standard'
    }
)

dynamodb = boto3.client('dynamodb', config=boto_config)
ssm = boto3.client('ssm', config=boto_config)

table_key = 'insults-lambda-table'

param = ssm.get_parameter(
    Name=table_key,
    WithDecryption=False
)

if "Parameter" not in param or "Value" not in param["Parameter"]:
    raise "Missing the %s parameter" % table_key

table = param["Parameter"]["Value"]

# TODO this should fetch (and create) a map of Slack URLs so we can support multiple
# webhooks/character quotations.

def get_slack_url():
    return get_value('S', "insults#slack")


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

# TODO - insults#character#messages#%s - allow us to get a message for a specific character.


def get_message(index):
    return get_value("S", "insults#messages#%s" % index)

# TODO - figure out how to iterate ALL messages or just messages for each character.


iterator_key = "insults#iterator"


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

# TODO - implement multiple iterators as above - this will need to target specific iterators.

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

# TODO - implement multiple iterators as above - this will need to target specific iterators.

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

# TODO - implement multiple iterators as above - this will need to target specific iterators.

def put_message(key, message):
    response = dynamodb.put_item(
        TableName=table,
        Item={
            'k': {
                'S': key
            },
            'v': {
                'S': message
            }
        }
    )
    return response

# TODO - fetch lines for a given character or loop through all files, creating quotes for all characters.

def create_messages():
    messages = []
    with open("lines.txt") as file:
        for line in file:
            line = line.strip()
            messages.append(line)
    random.shuffle(messages)
    i = 0
    for key, message in enumerate(messages):
        i += 1
        dynamo_key = "insults#messages#%s" % key
        put_message(dynamo_key, message)

    # Tells us how many messages exist, so we know when to reset the loop.
    put_message("insults#count", i)

# TODO - look for a parameter which matches a character name (see the map, at top of file).
# TODO - if present, pick a quote from that character. Otherwise, pick a character at random
# TODO - and trigger the next message for that one. 

def handle(event, context):
    body = dict(urlparse.parse_qsl(base64.b64decode(str(event['body'])).decode('ascii')))

    webhook_url = get_slack_url()
    if webhook_url is None:
        raise "Missing webhook URL"

    channel = "#%s" % body["channel_name"]

    i = get_iterator()
    m = get_value('S', "insults#count")

    # Ensure that messages are always in place. Shuffle to keep things interesting.
    if i < 1:
        create_messages()

    # Reset the loop.
    if i > m-1:
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
