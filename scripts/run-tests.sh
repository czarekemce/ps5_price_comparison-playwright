#!/bin/bash

cd /app/playwright-tests/
npx playwright test

# Upload pliku niezależnie od wyniku testów
echo "Uploading prices.txt to S3 regardless of test results..."
aws s3 cp /app/prices.txt s3://testowy-bucket-number-xx8/prices.txt

# Sprawdź status uploadu
if [ $? -eq 0 ]; then
    echo "Upload successful."
else
    echo "Upload failed."
    exit 1
fi
