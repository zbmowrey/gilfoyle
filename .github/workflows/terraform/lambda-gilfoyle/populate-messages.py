import boto3
from botocore.config import Config
import json
import requests
import random

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


def create_messages():
    messages = [
        "The history of humanity is a book written in blood. We’re all just animals in a pit.",
        "At least it didn’t happen in a public and brutally embarrassing way.",
        "I’m sure you can find your way out with one of your two faces.",
        "I’m effectively leveraging your misery. I’m like the Warren Buffet of fucking with you.",
        "A millionaire that gets peed on? I could see you making half that happen.",
        "There are very few things that I will defend with true passion: medical marijuana, the biblical Satan as a metaphor for rebellion against tyranny, and mother fucking Goddamn cryptocurrency.",
        "Ergo, I would like to be a helpful idiot. Like yourself.",
        "What we saw was a very oily man in mid-sentence dip down, vomit, and then thrust himself  violently face first into a glass wall. But I guess it's a lot less embarrassing the way you explain it.",
        "It's hard to believe your pathological inability to make a decision finally paid off.",
        "Our process sucks. Your inability to stop us from sucking is a failure of leadership.",
        "I'm not one to gush, but the possibilities of your consequence-free reality are darkly promising.",
        "Okay. I grant you, with... the benefit of even a second's distance, this isn't a good look.",
        "The one good thing that came out of you slapping your body against that cyberterrorist in a vulgar parody of the act of love is that we finally have a network with real security value.",
        "I'll go balls deep on your inbox.",
        "I could write better Python with my asshole.",
        "Thanks for asking. I'm going to put this as delicately as I know how. You can chortle my balls.",
        "In other words, you sit around and look at dick pics all day long. Don't let me stop you.",
        "I think you might be the first Pakistani man to be killed by a drone inside the United States.",
        "Spoken like a true leader. But since your failure as a leader is a virtual certainty, tolerating your short reign as CEO in exchange for a front-row seat to the disaster seems fair.",
        "If my mother was naked and dead in the street I would not cover her body with \"that\" jacket.",
        "Let me put this in terms you'll understand. I'm like a suicide bomber of humiliation. I'm happy to go out as long as I take you with me. Your shame is my paradise. ",
        "If you worked half as hard on the platform as you do trying to ogle strange Slavic women, maybe our shares would finally be worth something.",
        "Either she froze time, met and married the man of her dreams, unfroze time, and hopped back on to vid chat with you, or... you're the dogface. Which do you think it is? I'm on the fence. ",
        "Says here that she's looking for a man on the go. You don't \"go\" anywhere.",
        "My feeling is if you're the CEO of a company and you're dumb enough to leave your login info on a Post-it note on your desk, while the people that you fucking ripped off are physically in your office, it's not a hack. It's barely social engineering. It's more like natural selection.",
        "Pretend you've seen a woman before.",
        "You'd like to fuck my code, wouldn't you? Hey, would you like to masturbate to the subroutine I just wrote?",
        "You're gay for my code. You're code gay!",
        "I find parades to be impotent displays of authoritarianism.",
        "It has all that going for it, Richard, and I still hate it.",
        "Did it take you a long time? I'm glad I didn't do it then.",
        "Are you saying 'work will set you free'?",
        ":middle_finger: How does this translate into Farsi?",
        "Look, you have two guys on either side with their dicks, tip to tip, so you're going full-length. Four, see?",
        "The measurement that we're looking for, really, is dick to floor. Call that D2F.",
        "Unless you can hotswap dicks in and out.",
        "He's not gonna do shit. He's a coder. By definition, we're all pussies.",
        "Why don't we livestream me killing you?",
        "I bet you're right. He probably is just ripping his hair out somewhere. I wish I could see that.",
        "It is a mystery why you think you'll ever see a woman naked.",
        "My servers could handle 10 times the traffic if they weren't busy apologizing for your shit codebase.",
    ]
    random.shuffle(messages)
    random.shuffle(messages)
    random.shuffle(messages)
    for key, message in enumerate(messages):
        dynamo_key = "gilfoyle#messages#%s" % key
        put_message(dynamo_key, message)


create_messages()
