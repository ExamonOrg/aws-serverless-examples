import boto3
from schema import make_tables, TABLE
from ingest import ingest_events
import sys
import pprint
import asyncio
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


async def main(dynamodb_client):
    if len(sys.argv) != 2:
        print("No arguments provided.")
        return

    if sys.argv[1] == 'create':
        if check_table_exists(TABLE):
            dynamodb_client.delete_table(TableName=TABLE)
        make_tables(dynamodb_client)
    elif sys.argv[1] == 'ingest':
        await ingest_events('tx.csv', dynamodb_client)


if __name__ == '__main__':
    asyncio.run(main(dynamodb_client))
