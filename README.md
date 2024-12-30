A real-time price monitoring program for PS5 consoles that checks prices every hour at three selected online stores. If the price drops below $2,000, the system automatically sends an email notification to the designated address.

IaC - terraform
Tests - playwright.ts
Environment - linux commands & bash scripts
Notifications - terraform & python

Resources:
EC2, S3, Lambda, SNS

The prerequisite is to connect to your AWS account via CLI and install terraform.

1. git clone
2. go to config.txt file and change email value.
3. go to /scripts directory and run: bash generate-tfvars.sh
4. go to /infra directory and run: terraform init
5. run: terraform apply -var-file=config.tfvars

Now, you should receive an email from AWS to confirm subscription - it allows AWS to send price-alerts emails. You have to do this before the tests end. After a few tens of seconds, if the conditions are met, you should get an email notification
