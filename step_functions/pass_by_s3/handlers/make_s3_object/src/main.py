import boto3
from os import environ
import json
from uuid import uuid4


def lambda_handler(event: dict, context):
    print("event", event)
    print("context", context)
    bucket_name = environ['BUCKET_NAME']
    uuid = str(uuid4())

    s3 = boto3.resource('s3', region_name='eu-west-1')
    s3.Object(bucket_name, f'{uuid}.json').put(
        Body=(json.dumps({
            "uuid": uuid
        }, indent=4))
    )
    return {"file": f'{uuid}.json'}
