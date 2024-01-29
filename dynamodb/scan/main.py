import boto3
from schema import make_tables, TABLE_NAME
import sys
import pprint
import botocore
from boto3.dynamodb.conditions import Attr

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


def main(dynamodb_client, dynamodb_resource):
    if len(sys.argv) != 2:
        print("No arguments provided.")
        return

    if sys.argv[1] == 'create':
        if check_table_exists(TABLE_NAME):
            dynamodb_client.delete_table(TableName=TABLE_NAME)
        make_tables(dynamodb_client)
    elif sys.argv[1] == 'ingest':
        try:
            for year in range(2000, 2020):
                for data in [
                    {'model': f'{year} Falcon', 'make': "Ford", 'year': str(year), "price": "2", "frozen": "yes"},
                    {'model': f'{year} Bluebird', 'make': "Ford", 'year': str(year), "price": "2", "frozen": "yes"},
                    {'model': f'{year} SUV', 'make': "Ford", 'year': str(year), "price": "2", "frozen": "yes"},

                ]:
                    dynamodb_client.put_item(
                        TableName=TABLE_NAME,
                        Item={
                            'Model': {'S': data['model']},
                            'Make': {'S': data['make']},
                            'Year': {'S': data['year']},
                            "Price": {"N": data['price']},
                            "Frozen": {"S": data['frozen']}
                        }
                    )
        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] != 'ConditionalCheckFailedException':
                raise

    elif sys.argv[1] == 'query':
        response = dynamodb_client.scan(
            TableName=TABLE_NAME,
            FilterExpression='#mk = :make',
            ExpressionAttributeNames={
                '#mk': 'Make',
            },
            ExpressionAttributeValues={
                ':make': {'S': 'Ford'},
            },
            ConsistentRead=False,
            Limit=20,
        )

        pp.pprint(response['Items'])

    elif sys.argv[1] == 'partiql':
        statement = f'SELECT * FROM "{TABLE_NAME}" WHERE Make=?'
        params = [{'S': 'Ford'}]
        result = dynamodb_client.execute_statement(
            Statement=statement, Parameters=params
        )
        print(result)


if __name__ == '__main__':
    main(dynamodb_client, dynamodb_resource)
