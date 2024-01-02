def handler(event, context):
    index = event['iterator']['index']
    step = event['iterator']['step']
    count = event['iterator']['count']

    index += step

    return {
        'index': index,
        'step': step,
        'count': count,
        'continue': index < count
    }
