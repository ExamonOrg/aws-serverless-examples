import boto3
import json

if __name__ == '__main__':
    client = boto3.client('stepfunctions', region_name='eu-west-1')

    definition = {
        "Type": "Pass",
        "Result": "Hello",
        "Next": "World"
    }

    json_str = str(json.dumps(definition))
    result = client.test_state(
        definition=json_str,
        input=str(json.dumps({})),
        roleArn="arn:aws:iam::478119378221:role/sfnteststaterole",
        inspectionLevel='INFO',
        revealSecrets=True
    )

    print(result)

    result = client.test_state(
        definition=(str(json.dumps(
            {
                "Type": "Choice",
                "Choices": [
                    {
                        "Variable": "$.Status",
                        "StringEquals": "Approved",
                        "Next": "ApprovedPassState"
                    },
                    {
                        "Variable": "$.Status",
                        "StringEquals": "Rejected",
                        "Next": "RejectedPassState"
                    }
                ]
            }
        ))),
        input=str(json.dumps(
            {
                "Status": "Approved"
            }
        )),
        roleArn="arn:aws:iam::478119378221:role/sfnteststaterole",
        inspectionLevel='INFO',
        revealSecrets=True
    )

    print('------------------------')
    print(result)

    result = client.test_state(
        definition=(str(json.dumps(
            {
                "Type": "Task",
                "Resource": "arn:aws:lambda:eu-west-1:478119378221:function:enricher",
                "End": True
            }
        ))),
        roleArn="arn:aws:iam::478119378221:role/sfnteststaterole",
        inspectionLevel='INFO',
        revealSecrets=True
    )
    print('------------------------')

    print(result)
