import csv
import asyncio
from schema import TABLE
import time

from random import randrange


async def insert(dynamodb, pk, type, amount):
    time.sleep(randrange(10) / 1000)
    if type == 'DEPOSIT':
        statement = f'UPDATE {TABLE} SET balance = balance + ? WHERE PK=?'
    elif type == 'WITHDRAW':
        statement = f'UPDATE {TABLE} SET balance = balance - ? WHERE PK=?'
    params = [{'N': amount}, {'S': pk}, {'S': '1990'}]
    dynamodb.execute_statement(
        Statement=statement, Parameters=params
    )


async def ingest_events(csv_file_name, dynamodb):
    dynamodb.put_item(
        TableName=TABLE,
        Item={
            'PK': {'S': 'account101'},
            'balance': {'N': '0'},
            'history': {'L': []},
        }
    )
    with open(csv_file_name, newline='') as csvfile:
        data = list(csv.reader(csvfile))

    res = await asyncio.gather(
        *[insert(dynamodb, 'account101', d[0], d[1]) for d in data]
    )
