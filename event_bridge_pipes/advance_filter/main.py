import boto3

region = 'eu-west-1'
account_id = '478119378221'
queue_url = f'https://sqs.{region}.amazonaws.com/{account_id}/'


class SqsManager:
    def __init__(self, region, account_id):
        self.region = region
        self.queue_url = f'https://sqs.{region}.amazonaws.com/{account_id}/'

    def send_to_sqs(self, queue, message):
        client = boto3.client('sqs', region_name=self.region)
        full_path = f'{queue_url}{queue}'
        response = client.send_message(
            QueueUrl=full_path,
            MessageBody=message
        )
        print(f"sent message to {full_path}")

        return response

    def purge_queue(self, queue):
        sqs = boto3.client('sqs', region_name=self.region)
        full_path = f'{queue_url}{queue}'
        sqs.purge_queue(QueueUrl=full_path)
        print(f"Purged {full_path}")


if __name__ == '__main__':
    manager = SqsManager('eu-west-1', '478119378221')
    # messages that get through the filter
    # ["Your message here", "Your message there"]

    # manager.send_to_sqs('example-source', 'Your message there')
    manager.send_to_sqs('enrichment_source', 'Your message there')
    # send_to_sqs(source, "Your message there")
