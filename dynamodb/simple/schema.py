S = 'S'  # string type
N = 'N'  # number type
HASH = 'HASH'  # the Partition key
RANGE = 'RANGE'  # the Sort key
TABLE = 'single_table_design'  # the Table resource type


# composite key
def make_tables(dynamodb):
    dynamodb.create_table(
        AttributeDefinitions=[
            {
                'AttributeName': 'PK',
                'AttributeType': S
            },
            {
                'AttributeName': 'SK',
                'AttributeType': S
            },
        ],
        KeySchema=[
            {
                'AttributeName': 'PK',
                'KeyType': HASH,
            },
            {
                'AttributeName': 'SK',
                'KeyType': RANGE,
            },
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 5,  # The maximum number of strongly consistent reads
            'WriteCapacityUnits': 5,  # and writes consumed per second
        },
        # my table name
        TableName=TABLE,
    )
