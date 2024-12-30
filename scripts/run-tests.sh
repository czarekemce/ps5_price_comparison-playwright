#!/bin/bash

cd /app/playwright-tests/
npx playwright test

# Upload pliku
echo "Uploading prices.txt to S3 regardless of test results..."
aws s3 cp /app/playwright-tests/prices.txt s3://testowy-bucket-number-xx8/prices.txt

# Sprawdź status uploadu
if [ $? -eq 0 ]; then
    echo "Upload successful."
else
    echo "Upload failed."
    exit 1
fi
