import boto3
from schema import make_tables, TABLENAME
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
        if check_table_exists(TABLENAME):
            dynamodb_client.delete_table(TableName=TABLENAME)
        make_tables(dynamodb_client)
    elif sys.argv[1] == 'ingest':
        try:
            for data in [
                {'model': "Toyota", 'year': "1990", "price": "1", "frozen": "yes"},
                {'model': "Ford", 'year': "1990", "price": "2", "frozen": "yes"},
                {'model': "Ford", 'year': "1991", "price": "3", "frozen": "yes"},
            ]:
                dynamodb_client.put_item(
                    TableName='cars2',
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
            for return_value in ["ALL_OLD", "ALL_NEW", "UPDATED_OLD", "UPDATED_NEW"]:
                result = dynamodb_client.update_item(
                    TableName=TABLENAME,
                    Key={
                        'Model': {'S': 'Ford'},
                        'Year': {'S': '1990'}
                    },
                    ExpressionAttributeValues={
                        ':p': {"N": "22"}
                    },
                    ExpressionAttributeNames={
                        '#Price': 'Price'
                    },
                    UpdateExpression='SET #Price = :p',
                    ReturnValues=return_value,
                )
                print("return_value: ", return_value)
                pp.pprint(result)



if __name__ == '__main__':
    main(dynamodb_client, dynamodb_resource)
