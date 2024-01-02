import json
import boto3


class Sns:
    def __init__(self, arn):
        self.client = boto3.client('sns', region_name='eu-west-1')
        self.arn = arn


class Publisher(Sns):
    def publish(self, message):
        message = {"foo": message}
        self.client.publish(
            TargetArn=self.arn,
            Message=json.dumps({'default': json.dumps(message)}),
            MessageStructure='json'
        )


class Subscriber(Sns):
    # http https email email sms sqs application lambda firehose
    def subscribe(self):
        self.client.subscribe(
            TopicArn=self.arn,
            Protocol='sqs'
        )

# Differences Between Amazon SQS and SNS
# The core distinction between SQS and SNS lies in their architectural style and communication model.
# SQS is a pull-based (or polling) system, which means the consumer must actively check for and retrieve messages from
# the queue. It is ideal when you want to process messages in an exact sequence or if you need to ensure a message is
# processed only once.

if __name__ == '__main__':
    account_id = '478119378221'
    topic = 'my-topic'
    arn = f'arn:aws:sns:eu-west-1:{account_id}:{topic}'
    Publisher(arn).publish('hello there')
    print('published')

