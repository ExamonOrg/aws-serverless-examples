import boto3
from os import environ
import json


def lambda_handler(event: dict, context):
    bucket_name = environ['BUCKET_NAME']
    s3 = boto3.resource('s3', region_name='eu-west-1')

    file = event['file']
    obj = s3.Object(bucket_name, file)
    print(obj)
    data = obj.get()['Body']

    print(data)
    obj = json.load(data)
    obj["signed"] = True
    print("obj", obj)

    s3.Object(bucket_name, file).put(Body=(json.dumps(obj, indent=4)))

    return {
        "file": file
    }
