resource "local_file" "env_file" {
  filename = "../../frontend/.env"
  content  = "REACT_APP_LAMBDA_URL=${aws_lambda_function_url.lambda_backend_url.function_url}"
}

resource "null_resource" "lambda_frontend_npm_install" {
  depends_on = [local_file.env_file]
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "npm install && npm run build"
    working_dir = "../../frontend"
  }
}

data "archive_file" "frontend_package" {
  depends_on  = [null_resource.lambda_frontend_npm_install]
  type        = "zip"
  source_dir  = "../../frontend/dist"
  output_path = "./frontend.zip"
}

resource "aws_lambda_function" "lambda_frontend" {
  depends_on = [data.archive_file.frontend_package]

  function_name    = "${local.user_id}-frontend-lambda"
  role             = aws_iam_role.lambda_frontend_role.arn
  handler          = "bootstrap"
  source_code_hash = data.archive_file.package.output_base64sha256
  runtime          = "provided.al2"
  filename         = "./frontend.zip"
  memory_size      = 2048
  layers = [
    "arn:aws:lambda:${var.region}:753240598075:layer:LambdaAdapterLayerX86:22",
    "arn:aws:lambda:${var.region}:753240598075:layer:Nginx123X86:12"
  ]
}

resource "aws_lambda_function_url" "lambda_frontend_url" {
  function_name      = aws_lambda_function.lambda_frontend.function_name
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
resource "aws_iam_role" "lambda_frontend_role" {
  name                 = "sc-role-servicerole-${local.user_id}-lambda-frontend-role"
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

resource "aws_iam_role_policy_attachment" "lambda_frontend_execution" {
  role       = aws_iam_role.lambda_frontend_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_cloudwatch_log_group" "lambda_frontend_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_frontend.function_name}"
  retention_in_days = 5
}

