This project leverages AWS Lambda and SNS to deliver statistics on my favorite Brazilian football team, Corinthians from the 2022 season. Using Terraform for IaC, I automated the deployment of the following components:

1. Used Terraform as IaC to deploy different AWS services such as Lambda, SNS, and IAM roles and policies to ensure reliable workflow.
2. Developed a Python script to give user a better sense of readability while fetching data from a third party API.
3. Leveraged SNS which acts as a central communication channel, receiving data from the Lambda function and distributing it to subscribers.
4. To get the right information, I carefully selected the API endpoints and parameters to retrieve specific data points.


By subscribing to the SNS topic, I receive timely updates and insights into Corinthians' performance in 2022.

Cloud Architecture

![image](https://github.com/user-attachments/assets/24b9a036-0358-4d85-b717-450bbfc5f5cf)



