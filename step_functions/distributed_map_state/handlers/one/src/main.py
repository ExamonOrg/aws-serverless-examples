def lambda_handler(event: dict, context):
    print("Received Input:\n", event);

    return {
        'statusCode': 200,
        'inputReceived': event # returns the input that it received
    }
