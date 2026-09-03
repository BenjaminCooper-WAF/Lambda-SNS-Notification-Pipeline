# Lambda → SNS Notification Pipeline

![AWS](https://img.shields.io/badge/AWS-CLOUD-F3702A?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/TERRAFORM-%E2%89%A51.5-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS Lambda](https://img.shields.io/badge/AWS_Lambda-Serverless-FF9900?style=for-the-badge&logo=awslambda&logoColor=white)
![Amazon SNS](https://img.shields.io/badge/Amazon_SNS-Pub%2FSub-DD344C?style=for-the-badge&logo=amazonsimpleemailservice&logoColor=white)
![IAM](https://img.shields.io/badge/AWS_IAM-Least_Privilege-DD344C?style=for-the-badge&logo=amazoniam&logoColor=white)
![CloudWatch](https://img.shields.io/badge/CloudWatch-Logging-759C3E?style=for-the-badge&logo=amazoncloudwatch&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)

## Mission Objective

* Stand up a fully serverless, Terraform-defined pipeline where an **AWS Lambda** function behind a public **Function URL** publishes to an **Amazon SNS** topic that emails every confirmed subscriber, secured by least-privilege **IAM** and traced end-to-end in **CloudWatch Logs**.

## Architecture

```mermaid
flowchart LR
    A([Client / Browser]) -->|HTTPS request| B["Lambda Function URL"]
    B --> C["AWS Lambda\nlambda_function.py"]
    C -->|sns:Publish| D[("SNS Topic\nlambda-to-sns-topic")]
    C -->|logs:PutLogEvents| E["CloudWatch Logs"]
    D -->|email| F([Subscriber Inbox])
```

Everything above — the topic, the IAM role/policy, and the function itself — is defined as code in [`main.tf`](main.tf) and provisioned with a single `terraform apply`.

## Checkpoints

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Step-1: Provision the SNS Topic & IAM Role](#step-1-provision-the-sns-topic--iam-role)
4. [Step-2: Package & Deploy the Lambda Function](#step-2-package--deploy-the-lambda-function)
5. [Step-3: Expose & Trigger the Function URL](#step-3-expose--trigger-the-function-url)
6. [Step-4: Verify Execution in CloudWatch](#step-4-verify-execution-in-cloudwatch)
7. [Step-5: Subscribe & Confirm Email Delivery](#step-5-subscribe--confirm-email-delivery)
8. [Step-6: Live Notifications](#step-6-live-notifications)
9. [Errors](#errors)
10. [Deliverables](#deliverables)
11. [Teardown](#final-step---teardown)
12. [Author](#author)

## Prerequisites

* An AWS account with console + CLI access
* [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.5.0`
* Visual Studio Code (or any editor)
* Python 3.12 (matches the Lambda runtime)
* Patience & lots of coffee



## Step-1 (Provision the SNS Topic & IAM Role)

`main.tf` creates the `aws_sns_topic` that will fan out notifications, plus an `aws_iam_role` scoped to exactly two things: writing CloudWatch logs and publishing to that one topic.

![SNS topic created successfully](Images/topiccreation.jpg "SNS topic created")

![IAM role with AmazonSNSFullAccess and AWSLambdaBasicExecution policies attached](Images/roles.jpg "IAM role permissions")

## Step-2 (Package & Deploy the Lambda Function)

Terraform's `archive_file` data source zips [`lambda_function.py`](lambda_function.py) and deploys it as a Python 3.12 Lambda. The function reads the topic ARN from an environment variable and publishes a JSON payload on every invocation.

![Lambda function deployed with source code visible in the console editor](Images/Lambascript.jpg "Lambda function code")

![SNS_TOPIC_ARN environment variable configured on the function](Images/Environmentvariables.jpg "Environment variables")

## Step-3 (Expose & Trigger the Function URL)

A public Function URL turns the Lambda into a one-click HTTP trigger — handy for testing without needing API Gateway or the CLI.

![Function URL enabled with auth type NONE](Images/Functionurl.jpg "Function URL")

![JSON response returned after invoking the Function URL](Images/Messageprint.jpg "Invocation response")

## Step-4 (Verify Execution in CloudWatch)

Every invocation is traced end-to-end in CloudWatch Logs — the `sns.publish()` response (including the returned `MessageId`), plus the billed duration and memory usage.

![CloudWatch log stream showing successful publishResult entries](Images/Cloudwatchlogs.jpg "CloudWatch logs")

## Step-5 (Subscribe & Confirm Email Delivery)

Before a subscriber can receive anything, SNS sends a confirmation link. Once it's clicked, the subscription flips to `Confirmed` and the topic is ready to deliver.

![SNS subscription confirmation email in Gmail](Images/Subscription.jpg "Confirmation email")

![Subscription confirmed page returned by SNS](Images/SNS.jpg "Subscription confirmed")

![SNS topic showing one confirmed EMAIL subscription](Images/topicactive.jpg "Confirmed subscription")

## Step-6 (Live Notifications)

With the subscription active, every Function URL hit results in a real email notification, timestamped by the Lambda at invocation time.

![Email notification with Lambda invocation timestamp](Images/Lambainvoked.jpg "Notification email")

![Inbox showing a stream of timestamped notification emails from repeated invocations](Images/Email-pings.jpg "Notification stream")

## Errors

* `AccessDenied` on `sns:Publish` — the IAM policy's `Resource` must match the topic's ARN exactly; double-check region/account ID.
* Function URL returns `{"Message":null}` — this is CloudFront/API Gateway's default 200 response body when the Lambda return value doesn't map cleanly to the console's raw view; check CloudWatch Logs for the real `publishResult`, not the browser output.
* No email arrives — the subscription is still `PendingConfirmation`; check spam/junk for the confirmation email and click the link before testing again.

## Deliverables

* A working, fully Terraform-managed serverless pipeline: Lambda → SNS → Email, with least-privilege IAM and CloudWatch observability.
* Screenshots of every stage captured for the record — see the [`Images/`](Images) folder.
* Congrats, you have successfully completed your mission and are now ready for more pain.

## Teardown

Unless you can print your own money, you will need to tear down your deployment.

```bash
terraform destroy
```

* You will be asked to confirm deletion — say yes.
* Double check your AWS console that the SNS topic, IAM role, and Lambda function are gone.
* Triple check everything — Jeff Bezos has enough money.

## Author

**Benjamin Cooper**
