resource "aws_sns_topic" "email_topic" {
    name = "brasileirao_topic"
}

data "aws_sns_topic" "my_sns_topic_data" {
    name = aws_sns_topic.email_topic.name
  
}


resource "aws_lambda_function" "test_lambda" {
  filename      = data.archive_file.lambda.output_path
  function_name = "Standings"
  role          = aws_iam_role.lambda_role.arn
  handler       = "standings.lambda_handler"
  timeout = 10

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.13"

  environment {
    variables = {
      "SNS_TOPIC_ARN" = aws_sns_topic.email_topic.arn
    }
  }

}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/standings.py"
  output_path = "${path.module}/lambda_function.zip"
}

data "aws_iam_policy_document" "sns_lambda_policy" {
  
  statement {
    sid     = ""
    effect  = "Allow"

    actions = [
      "sns:Publish",
    ]
    resources = [
        "aws_sns_topic.brasileirao_topic.arn"
    ]
    
  }
}
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_sns_access" {
  name = "lambda_sns_access"
  role = aws_iam_role.lambda_role.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": "${aws_sns_topic.brasileirao_topic.arn}" 
    }
  ]
}
EOF
}

resource "aws_sns_topic" "brasileirao_topic" {
  name = "brasileirao_topic"
}