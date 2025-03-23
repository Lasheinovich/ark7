from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    response = client.get(f"/health")
    assert response.status_code == 200
    assert "Health Route" in response.json().values()
