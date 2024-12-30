provider "aws" {
  region = "eu-central-1" 
}

# EC2 Instance
resource "aws_instance" "playwright_instance" {
  ami           = "ami-0a628e1e89aaedf80"
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    sudo apt install -y nodejs git
    npm cache clean --force

    mkdir /app
    cd /app
    git clone https://github.com/czarekemce/ps5_price_comparison-playwright-terraform-python-AWS.git .
    npm install @playwright/test 
    npx playwright install
    npx playwright install-deps
    echo "email=${var.email}" > /app/config.txt

    sudo pip install boto3

    sudo apt install -y cron
    sudo systemctl enable cron
    sudo systemctl start cron

    sudo apt update -y
    sudo apt install -y unzip curl
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    sudo chmod -R 777 /app/
    /app/scripts/run-tests.sh
    (crontab -l 2>/dev/null; echo "0 * * * * /app/scripts/run-tests.sh") | crontab -
  EOF


  tags = {
    Name = "PlaywrightInstance"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "price_file" {
  bucket = "testowy-bucket-number-xx8"

  tags = {
    Name        = "TestResultsBucket"
    Environment = "Dev"
  }
}

# IAM Role for S3 Access
resource "aws_iam_role" "ec2_role" {
  name = "EC2S3AccessRole"

  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  EOF
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy to allow S3 access for EC2"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:DeleteObject"
          ],
          "Resource": [
            "arn:aws:s3:::testowy-bucket-number-xx8/*",
            "arn:aws:s3:::testowy-bucket-number-xx8"

          ]
        }
      ]
    }
  EOF
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}

# Rola IAM dla funkcji Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Polityka IAM dla Lambda (dostęp do S3 i SNS)
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Policy for Lambda to access S3 and SNS"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.price_file.bucket}/*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.price_alerts.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Funkcja Lambda
resource "aws_lambda_function" "price_check_lambda" {
  filename         = "lambda.zip"
  function_name    = "PriceCheckLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda.zip")
}

# Powiadomienie S3, aby uruchomić funkcję Lambda po załadowaniu pliku
resource "aws_s3_bucket_notification" "price_file_notification" {
  bucket = aws_s3_bucket.price_file.id

  lambda_function {
    events     = ["s3:ObjectCreated:*"]
    lambda_function_arn = aws_lambda_function.price_check_lambda.arn
  }
}

# Uprawnienia dla S3, aby mogło wywoływać funkcję Lambda
resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.price_check_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.price_file.arn
}

# Zasób SNS - temat powiadomień
resource "aws_sns_topic" "price_alerts" {
  name = "price-alerts"
}

# Subskrypcja SNS - powiadomienie email
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.price_alerts.arn
  protocol  = "email"
  endpoint  = var.email
}
