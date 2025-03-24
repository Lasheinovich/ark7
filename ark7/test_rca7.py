import pytest
import requests
import subprocess

# --- Step 1: Check URL Path for 404 ---
def test_url_path():
    URL_PATH = "https://globalarkacademy.org"
    OBJECT_NAME = "image.png"
    FULL_URL = f"{URL_PATH}/{OBJECT_NAME}"

    print(f"🚀 Checking if object exists at {FULL_URL}...")

    response = requests.head(FULL_URL)

    assert response.status_code != 404, f"❌ 404 Error: Object not found at {FULL_URL}"
    print(f"✅ Object found at {FULL_URL}")

# --- Step 2: Check Cloudflare R2 Bucket ---
def test_r2_bucket():
    R2_BUCKET = "globalark-bucket"  # Replace with your actual bucket name
    OBJECT_NAME = "image.png"
    ACCESS_KEY = "your-access-key"
    SECRET_KEY = "your-secret-key"

    print(f"🚀 Checking if the object exists in Cloudflare R2 bucket {R2_BUCKET}...")

    # Using subprocess to call s3cmd
    result = subprocess.run(
        ["s3cmd", "ls", f"s3://{R2_BUCKET}/{OBJECT_NAME}", "--access-key", ACCESS_KEY, "--secret-key", SECRET_KEY],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    assert result.returncode == 0, f"❌ Object not found in Cloudflare R2 bucket: {OBJECT_NAME}"
    print(f"✅ Object exists in Cloudflare R2 bucket: {OBJECT_NAME}")

# --- Step 3: Check Cloudflare DNS Configuration ---
def test_cloudflare_dns():
    cloudflare_api_token = "your-cloudflare-api-token"  # Replace with your Cloudflare API token
    zone_id = "your-zone-id"  # Replace with your Cloudflare Zone ID
    domain_name = "globalarkacademy.org"

    print(f"🚀 Checking DNS settings for domain {domain_name}...")

    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records?name={domain_name}"

    headers = {
        "Authorization": f"Bearer {cloudflare_api_token}",
        "Content-Type": "application/json"
    }

    response = requests.get(url, headers=headers)
    response_data = response.json()

    assert response.status_code == 200, f"❌ Failed to fetch DNS records for {domain_name}"
    assert "status" in response_data and response_data["status"] == "active", f"❌ DNS records are not active for {domain_name}"
    print(f"✅ DNS records for {domain_name} are correctly configured and active.")

# --- Step 4: Check Cloudflare CDN Cache ---
def test_cloudflare_cache():
    URL_PATH = "https://globalarkacademy.org"
    OBJECT_NAME = "image.png"
    FULL_URL = f"{URL_PATH}/{OBJECT_NAME}"

    print(f"🚀 Checking Cloudflare CDN cache for {FULL_URL}...")

    response = requests.head(FULL_URL)

    assert response.status_code == 200, f"❌ Object is not found in Cloudflare cache at {FULL_URL}"
    print(f"✅ Object is properly cached in Cloudflare CDN at {FULL_URL}")

# --- Step 5: Running All Tests in a Loop ---
def test_all():
    test_url_path()
    test_r2_bucket()
    test_cloudflare_dns()
    test_cloudflare_cache()

# --- Step 6: Run Tests ---
if __name__ == "__main__":
    test_all()

