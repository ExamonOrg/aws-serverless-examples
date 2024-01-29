

S = 'S'  # string type
N = 'N'  # number type
HASH = 'HASH'  # the Partition key
RANGE = 'RANGE'  # the Sort key
TABLE_NAME = 'cars3'

# composite key
def make_tables(dynamodb):
    dynamodb.create_table(
        AttributeDefinitions=[
            {
                'AttributeName': 'Model',
                'AttributeType': S
            }
        ],
        KeySchema=[
            {
                'AttributeName': 'Model',
                'KeyType': HASH,
            }
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 5,  # The maximum number of strongly consistent reads
            'WriteCapacityUnits': 5,  # and writes consumed per second
        },
        # my table name
        TableName=TABLE_NAME,
    )
