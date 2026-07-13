import json
import os

import boto3

sns = boto3.client("sns")


def lambda_handler(event, context):
    topic_arn = os.environ["SNS_TOPIC_ARN"]

    message = {
        "message": "Hello from AWS Lambda",
        "event": event,
    }

    response = sns.publish(
        TopicArn=topic_arn,
        Subject="Lambda Notification",
        Message=json.dumps(message, default=str),
    )

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Message published to SNS",
                "message_id": response["MessageId"],
            }
        ),
    }