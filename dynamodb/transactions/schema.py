S = 'S'  # string type
HASH = 'HASH'  # the Partition key
RANGE = 'RANGE'  # the Sort key
TABLE = 'tnx'


# composite key
def make_tables(dynamodb):
    dynamodb.create_table(
        AttributeDefinitions=[
            {
                'AttributeName': 'PK',
                'AttributeType': S
            }
        ],
        KeySchema=[
            {
                'AttributeName': 'PK',
                'KeyType': HASH,
            }
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 5,  # The maximum number of strongly consistent reads
            'WriteCapacityUnits': 5,  # and writes consumed per second
        },
        # my table name
        TableName=TABLE,
    )
