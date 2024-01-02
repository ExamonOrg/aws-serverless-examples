
def handler(event, context):
    event['message'] = 'Hello from event_bridge_pipes!'
    return event
    print(event)
    print(context)