region = 'eu-west-1'


def lambda_handler(event: dict, context):
    print(f'Event: {event}')
    print(f'Context: {context}')
    ...