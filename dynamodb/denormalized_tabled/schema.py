

S = 'S'  # string type
N = 'N'  # number type
HASH = 'HASH'  # the Partition key
RANGE = 'RANGE'  # the Sort key


# composite key
def make_tables(dynamodb):
    dynamodb.create_table(
        AttributeDefinitions=[
            {
                'AttributeName': 'event_name',
                'AttributeType': S
            },
            {
                'AttributeName': 'card_placement',
                'AttributeType': N
            },
        ],
        KeySchema=[
            {
                'AttributeName': 'event_name',
                'KeyType': HASH,
            },
            {
                'AttributeName': 'card_placement',
                'KeyType': RANGE,
            },
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 5,  # The maximum number of strongly consistent reads
            'WriteCapacityUnits': 5,  # and writes consumed per second
        },
        # my table name
        TableName='ufc_matches_xyz',
    )

    dynamodb.create_table(
        AttributeDefinitions=[
            {
                'AttributeName': 'fighter_name',
                'AttributeType': S
            },
            {
                'AttributeName': 'fight_date',
                'AttributeType': S
            },
        ],
        KeySchema=[
            {
                'AttributeName': 'fighter_name',
                'KeyType': HASH,
            },
            {
                'AttributeName': 'fight_date',
                'KeyType': RANGE,
            },
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 5,  # The maximum number of strongly consistent reads
            'WriteCapacityUnits': 5,  # and writes consumed per second
        },
        # my table name
        TableName='ufc_fights_xyz',
    )
