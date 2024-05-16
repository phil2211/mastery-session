resource "null_resource" "lambda_backend_npm_install" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "npm install"
    working_dir = "../../backend"
  }

}

data "archive_file" "package" {
  depends_on  = [null_resource.lambda_backend_npm_install]
  type        = "zip"
  source_dir  = "../../backend"
  output_path = "./backend.zip"
}

resource "aws_lambda_function" "lambda_backend" {
  depends_on = [data.archive_file.package]

  function_name    = "${local.user_id}-backend-lambda"
  role             = aws_iam_role.lambda_backend_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.package.output_base64sha256
  runtime          = "nodejs20.x"
  filename         = "./backend.zip"
  timeout          = 60

  environment {
    variables = {
      SECRET_NAME = "/mongodb/${local.user_id}-project1/${local.user_id}-cluster/user/${local.user_id}-cluster-admin"
    }
  }
}

resource "aws_lambda_function_url" "lambda_backend_url" {
  function_name      = aws_lambda_function.lambda_backend.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["content-type", "access-control-allow-methods", "access-control-allow-origin"]
    expose_headers    = ["content-type", "access-control-allow-methods", "access-control-allow-origin"]
    max_age           = 0
  }
}

# Define the IAM role for the Lambda function
resource "aws_iam_role" "lambda_backend_role" {
  name                 = "sc-role-servicerole-${local.user_id}-lambda-role"
  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/sc-policy-cdk-pipeline-permission-boundary"

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

resource "aws_iam_role_policy_attachment" "lambda_backend_execution" {
  role       = aws_iam_role.lambda_backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_backend_bedrock" {
  role       = aws_iam_role.lambda_backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

resource "aws_iam_policy" "lambda_backend_secrets_manager_access" {
  name        = "lambda_secrets_manager_access"
  description = "IAM policy for allowing Lambda to access Secrets Manager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_backend_secrets_manager_access" {
  role       = aws_iam_role.lambda_backend_role.name
  policy_arn = aws_iam_policy.lambda_backend_secrets_manager_access.arn
}

resource "aws_cloudwatch_log_group" "lambda_backend_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_backend.function_name}"
  retention_in_days = 5
}

