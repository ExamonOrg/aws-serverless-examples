import boto3
from schema import make_tables, TABLE_NAME
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
        if check_table_exists(TABLE_NAME):
            dynamodb_client.delete_table(TableName=TABLE_NAME)
        make_tables(dynamodb_client)
    elif sys.argv[1] == 'ingest':
        table = dynamodb_resource.Table(TABLE_NAME)
        with table.batch_writer() as writer:
            for data in [
                {'Model': "Toyota", 'Year': "1990", "price": "1", "frozen": "yes"},
                {'Model': "Ford", 'Year': "1990", "price": "2", "frozen": "yes"},
                {'Model': "Ford", 'Year': "1991", "price": "3", "frozen": "yes"},
            ]:
                writer.put_item(Item=data)


if __name__ == '__main__':
    main(dynamodb_client, dynamodb_resource)
