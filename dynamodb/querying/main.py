import boto3
from schema import make_tables
from injest import ingest
from ingest_transaction import ingest_trnx
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
        if check_table_exists('ufc_matches'):
            dynamodb_client.delete_table(TableName='ufc_matches')
        make_tables(dynamodb_client)
    elif sys.argv[1] == 'ingest_transaction':
        ingest_trnx('UFC_EVENTS_DETAILED.csv', dynamodb_client)
    elif sys.argv[1] == 'ingest':
        ingest('UFC_EVENTS_DETAILED.csv', dynamodb_client)
    elif sys.argv[1] == 'query':
        # table = dynamodb.query(
        #     TableName='ufc_matches'
        # )

        table = dynamodb_resource.Table('ufc_matches')

        response = table.scan()
        data = response['Items']
        pp.pprint(len(data))

        response = dynamodb_client.get_item(
            ReturnConsumedCapacity='TOTAL',
            TableName='ufc_matches',
            Key={
                'event_name': {'S': 'UFC 280: Oliveira vs. Makhachev'},
                'card_placement': {'N': '1'}
            }
        )
        print(response['Item'])
        print('ConsumedCapacity', response['ConsumedCapacity'])

        response = table.get_item(
            ReturnConsumedCapacity='TOTAL',

            Key={
                'event_name': 'UFC 280: Oliveira vs. Makhachev',
                'card_placement': 1
            }
        )
        print(response['Item'])
        print('ConsumedCapacity', response['ConsumedCapacity'])

        response = dynamodb_client.query(
            TableName='ufc_matches',
            ReturnConsumedCapacity='TOTAL',

            KeyConditionExpression='event_name = :event_name',
            ExpressionAttributeValues={
                ':event_name': {'S': 'UFC 280: Oliveira vs. Makhachev'}
            }
        )
        print(len(response['Items']))
        print('ConsumedCapacity', response['ConsumedCapacity'])

        response = table.query(
            ReturnConsumedCapacity='TOTAL',
            KeyConditionExpression=Key('event_name').eq('UFC 280: Oliveira vs. Makhachev')
        )
        print(len(response['Items']))
        print('ConsumedCapacity', response['ConsumedCapacity'])

        response = dynamodb_client.query(
            TableName='ufc_matches',
            ReturnConsumedCapacity='TOTAL',

            KeyConditionExpression='event_name = :event_name AND card_placement <= :card_placement',
            ExpressionAttributeValues={
                ':event_name': {'S': 'UFC 280: Oliveira vs. Makhachev'},
                ':card_placement': {'N': '5'}
            }
        )
        print(len(response['Items']))
        print('ConsumedCapacity', response['ConsumedCapacity'])

        response = dynamodb_client.query(
            TableName='ufc_matches',
            ReturnConsumedCapacity='TOTAL',

            KeyConditionExpression='event_name = :event_name AND card_placement between :card_placement_start AND :card_placement_finish',
            ExpressionAttributeValues={
                ':event_name': {'S': 'UFC 280: Oliveira vs. Makhachev'},
                ':card_placement_start': {'N': '1'},
                ':card_placement_finish': {'N': '5'},
            }
        )
        print(len(response['Items']))
        print('ConsumedCapacity', response['ConsumedCapacity'])

        response = table.query(
            ReturnConsumedCapacity='TOTAL',
            KeyConditionExpression=Key('event_name').eq('UFC 280: Oliveira vs. Makhachev') & Key('card_placement').eq(2)
        )
        print(response['Items'])
        print('ConsumedCapacity', response['ConsumedCapacity'])

        response = table.query(
            ReturnConsumedCapacity='TOTAL',
            KeyConditionExpression=Key('event_name').eq('UFC 280: Oliveira vs. Makhachev') & Key('card_placement').lt(3),              
        )
        print(response['Items'])
        print('ConsumedCapacity', response['ConsumedCapacity'])

        response = table.query(
            ReturnConsumedCapacity='TOTAL',

            KeyConditionExpression=Key('event_name').eq('UFC 280: Oliveira vs. Makhachev') & Key('card_placement').between(1, 3)
        )
        print(response['Items'])
        print('ConsumedCapacity', response['ConsumedCapacity'])



if __name__ == '__main__':
    main(dynamodb_client, dynamodb_resource)
