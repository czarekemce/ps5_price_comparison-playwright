provider "aws" {
  region = "eu-central-1" 
}

# EC2 Instance
resource "aws_instance" "playwright_instance" {
  ami           = "ami-0e54671bdf3c8ed8d"
  instance_type = "t2.micro"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
    yum install -y nodejs git
    npm cache clean --force
    npm install playwright aws-sdk

    mkdir /app
    cd /app
    git clone https://github.com/czarekemce/ps5_price_comparison-playwright.git .
    chmod +x scripts/run-tests.sh

    sudo yum install -y cronie
    sudo systemctl enable crond
    sudo systemctl start crond

    /app/scripts/run-tests.sh
    (crontab -l 2>/dev/null; echo "0 * * * * /app/scripts/run-tests.sh") | crontab -
  EOF

  tags = {
    Name = "PlaywrightInstance"
  }
}

# S3 Bucket
variable "BUCKET_NAME" {
  description = "S3 bucket name"
}

resource "aws_s3_bucket" "price_file" {
  bucket = "var.BUCKET_NAME"

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
            "s3:GetObject"
          ],
          "Resource": [
            "arn:aws:s3:::var.BUCKET_NAME/*"
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
