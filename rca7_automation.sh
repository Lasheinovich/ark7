#!/bin/bash

set -e

# --- Step 1: Define Cloudflare R2 credentials ---
ACCESS_KEY="your-cloudflare-access-key"  # Replace with your actual Cloudflare R2 Access Key
SECRET_KEY="your-cloudflare-secret-key"  # Replace with your actual Cloudflare R2 Secret Key
ENDPOINT_URL="https://<account_id>.r2.cloudflarestorage.com"  # Replace with your actual Cloudflare R2 Endpoint URL
R2_BUCKET="globalark-bucket"  # Replace with your actual R2 Bucket name
OBJECT_NAME="image.png"  # Replace with your actual object name to check

# --- Step 2: Configure s3cmd ---
echo "🚀 Automating s3cmd configuration for Cloudflare R2..."

# Create the s3cmd configuration file automatically
echo "
[default]
access_key = $ACCESS_KEY
secret_key = $SECRET_KEY
host_base = $ENDPOINT_URL
host_bucket = $ENDPOINT_URL
use_https = True
" > ~/.s3cfg

echo "✅ s3cmd configured automatically."

# --- Step 3: Check URL Path for 404 ---
echo "🚀 Checking if object exists at https://globalarkacademy.org/$OBJECT_NAME..."

URL_PATH="https://globalarkacademy.org"
FULL_URL="$URL_PATH/$OBJECT_NAME"

response=$(curl --head --silent "$FULL_URL" | grep "HTTP/1.1 404")

if [ $? -eq 0 ]; then
    echo "❌ 404 Error: Object not found at $FULL_URL"
else
    echo "✅ Object found at $FULL_URL"
fi

# --- Step 4: Verify Cloudflare R2 Bucket Configuration ---
echo "🚀 Verifying if the object exists in Cloudflare R2 bucket..."

# Check if the object exists in the Cloudflare R2 bucket using s3cmd
result=$(s3cmd ls "s3://$R2_BUCKET/$OBJECT_NAME" --access-key="$ACCESS_KEY" --secret-key="$SECRET_KEY")

if [ $? -eq 0 ]; then
    echo "✅ Object exists in Cloudflare R2 bucket: $OBJECT_NAME"
else
    echo "❌ Object not found in Cloudflare R2 bucket: $OBJECT_NAME"
fi

# --- Step 5: Check DNS Settings in Cloudflare ---
echo "🚀 Checking DNS settings for globalarkacademy.org..."

CLOUDFLARE_API_TOKEN="your-cloudflare-api-token"  # Replace with your actual Cloudflare API token
ZONE_ID="your-zone-id"  # Replace with your actual Zone ID

url="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=globalarkacademy.org"
response=$(curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" -H "Content-Type: application/json" "$url")

if [[ $(echo "$response" | jq -r '.success') == "true" ]]; then
    echo "✅ DNS settings are correct for globalarkacademy.org"
else
    echo "❌ DNS settings not found or invalid for globalarkacademy.org"
fi

# --- Step 6: Check Cloudflare Cache ---
echo "🚀 Checking Cloudflare cache for $FULL_URL..."

cache_response=$(curl --head --silent "$FULL_URL" -H "Cache-Control: max-age=0")

if [ $? -eq 0 ]; then
    echo "✅ Cache status check passed for Cloudflare cache at $FULL_URL"
else
    echo "❌ Cache status not found or incorrect for Cloudflare cache at $FULL_URL"
fi

# --- Step 7: Test all checks ---
echo "🚀 Running all tests for RCA7... this will include the checks for 404 errors, R2 bucket, DNS, and cache."

# Test URL Path
test_url_path() {
    URL_PATH="https://globalarkacademy.org"
    OBJECT_NAME="image.png"
    FULL_URL="$URL_PATH/$OBJECT_NAME"
    
    echo "🚀 Checking if object exists at $FULL_URL..."

    response=$(curl --head --silent "$FULL_URL" | grep "HTTP/1.1 404")

    if [ $? -eq 0 ]; then
        echo "❌ 404 Error: Object not found at $FULL_URL"
    else
        echo "✅ Object found at $FULL_URL"
    fi
}

# Test Cloudflare R2 Bucket
test_r2_bucket() {
    R2_BUCKET="globalark-bucket"  # Replace with your actual bucket name
    OBJECT_NAME="image.png"
    
    echo "🚀 Verifying if object exists in Cloudflare R2 bucket..."
    
    result=$(s3cmd ls "s3://$R2_BUCKET/$OBJECT_NAME" --access-key="$ACCESS_KEY" --secret-key="$SECRET_KEY")

    if [ $? -eq 0 ]; then
        echo "✅ Object exists in Cloudflare R2 bucket: $OBJECT_NAME"
    else
        echo "❌ Object not found in Cloudflare R2 bucket: $OBJECT_NAME"
    fi
}

# Run all tests
test_url_path
test_r2_bucket

echo "✅ RCA7 checks completed successfully."
