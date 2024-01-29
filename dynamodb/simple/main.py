# Get the service resource.
import boto3
from schema import make_tables

dynamodb = boto3.client('dynamodb', endpoint_url='http://localhost:8000', region_name='us-west-2')

if __name__ == '__main__':
    dynamodb.delete_table(
        TableName='NHL_Teams'
    )
    make_tables(dynamodb)
    print(dynamodb.list_tables())
