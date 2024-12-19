#!/bin/bash

npx playwright test

source ../config.txt
echo $BUCKET_NAME

if [ $? -eq 0 ]; then
    echo "Tests passed. Uploading prices.txt to S3..."
    aws s3 cp prices.txt s3://$bucketname/prices.txt
else
    echo "Tests failed. Skipping S3 upload."
    exit 1
fi