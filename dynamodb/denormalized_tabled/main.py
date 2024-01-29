import boto3
from schema import make_tables
from injest import ingest
import sys
import pprint
from boto3.dynamodb.conditions import Key

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
        if check_table_exists('ufc_matches_xyz'):
            dynamodb_client.delete_table(TableName='ufc_matches_xyz')
            dynamodb_client.delete_table(TableName='ufc_fights_xyz')
        make_tables(dynamodb_client)
    elif sys.argv[1] == 'ingest':
        ingest('UFC_EVENTS_DETAILED.csv', dynamodb_client)



if __name__ == '__main__':
    main(dynamodb_client, dynamodb_resource)
