#!/bin/bash

cd /app/playwright-tests/
npx playwright test

if [ $? -eq 0 ]; then
    echo "Tests passed. Uploading prices.txt to S3..."
    aws s3 cp /app/prices.txt s3://testowy-bucket-number-xx8/prices.txt
else
    echo "Tests failed. Skipping S3 upload."
    exit 1
fi