provider "aws" {
  region = "eu-central-1" 
}

# EC2 Instance
resource "aws_instance" "playwright_instance" {
  ami           = "ami-0a628e1e89aaedf80"
  instance_type = "t2.micro"

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    sudo apt install -y nodejs git
    npm cache clean --force

    mkdir /app
    cd /app
    git clone https://github.com/czarekemce/ps5_price_comparison-playwright-AWS.git .
    npm install @playwright/test 
    npx playwright install
    npx playwright install-deps

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
  bucket = var.bucketname

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
            "arn:aws:s3:::${var.bucketname}",
            "arn:aws:s3:::${var.bucketname}/*"

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