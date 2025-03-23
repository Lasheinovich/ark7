from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_education():
    response = client.get(f"/education")
    assert response.status_code == 200
    assert "Education Route" in response.json().values()
