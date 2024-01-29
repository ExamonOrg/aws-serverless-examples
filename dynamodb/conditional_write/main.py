import boto3
from schema import make_tables
import sys
import pprint
import botocore

pp = pprint.PrettyPrinter(indent=4)

dynamodb_client = boto3.client(
    'dynamodb',
    endpoint_url='http://localhost:8000',
    region_name='eu-west-1'
)

dynamodb_resource = boto3.resource(
    'dynamodb',
    endpoint_url='http://localhost:8000',
    region_name='eu-west-1'
)


def check_table_exists(table_name):
    response = dynamodb_client.list_tables()
    return table_name in response['TableNames']


# https://www.fernandomc.com/posts/ten-examples-of-getting-data-from-dynamodb-with-python-and-boto3/
def main(dynamodb_client, dynamodb_resource):
    if len(sys.argv) != 2:
        print("No arguments provided.")
        return

    if sys.argv[1] == 'create':
        if check_table_exists('cars'):
            dynamodb_client.delete_table(TableName='cars')
        make_tables(dynamodb_client)
    elif sys.argv[1] == 'ingest':
        try:
            for data in [
                {'model': "Toyota", 'year': "1990", "price": "1", "frozen": "yes"},
                {'model': "Ford", 'year': "1990", "price": "2", "frozen": "yes"},
                {'model': "Ford", 'year': "1991", "price": "3", "frozen": "yes"},
            ]:
                dynamodb_client.put_item(
                    TableName='cars',
                    Item={
                        'Model': {'S': data['model']},
                        'Year': {'S': data['year']},
                        "Price": {"N": data['price']},
                        "Frozen": {"S": data['frozen']}
                    }
                )
        except botocore.exceptions.ClientError as e:
            # Ignore the ConditionalCheckFailedException, bubble up
            # other exceptions.
            if e.response['Error']['Code'] != 'ConditionalCheckFailedException':
                raise

    elif sys.argv[1] == 'update':
        for data in [
                {'model': "Toyota", 'year': "1990", "price": "11"},
                {'model': "Ford", 'year': "1990", "price": "22"},
                {'model': "Ford", 'year': "1991", "price": "33"}
        ]:
            try:
                dynamodb_client.update_item(
                        TableName='cars',
                        Key={
                            'Model': {'S': data['model']},
                            'Year': {'S': data['year']}
                        },
                        UpdateExpression='SET Price = :p',
                        ReturnValues="UPDATED_NEW",
                        ExpressionAttributeValues={
                            ':frozen': {"S": "no"},
                            ':p': {'N': data['price']}
                        },
                        # precondition, it is the value before
                        ConditionExpression='Frozen = :frozen'
                    )
            except botocore.exceptions.ClientError as e:
                # Ignore the ConditionalCheckFailedException, bubble up
                # other exceptions.
                print("did not update: ", data)
                if e.response['Error']['Code'] != 'ConditionalCheckFailedException':
                    raise

    elif sys.argv[1] == 'delete_nonFord':
        for data in [
            {'model': "Toyota", 'year': "1990"},
            {'model': "Ford", 'year': "1990"},
            {'model': "Ford", 'year': "1991"}
        ]:
            try:
                dynamodb_client.delete_item(
                        TableName='cars',
                        Key={
                            'Model': {'S': data['model']},
                            'Year': {'S': data['year']}
                        },
                        ExpressionAttributeValues={
                            ':model': {"S": "Ford"}
                        },
                        ExpressionAttributeNames={
                            '#Model': 'Model'
                        },
                        # precondition, it is the value before
                        ConditionExpression='#Model <> :model'
                    )
            except botocore.exceptions.ClientError as e:
                # Ignore the ConditionalCheckFailedException, bubble up
                # other exceptions.
                print("did not delete: ", data)
                if e.response['Error']['Code'] != 'ConditionalCheckFailedException':
                    raise






if __name__ == '__main__':
    main(dynamodb_client, dynamodb_resource)
