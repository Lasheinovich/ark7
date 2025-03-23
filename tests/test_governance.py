from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_governance():
    response = client.get(f"/governance")
    assert response.status_code == 200
    assert "Governance Route" in response.json().values()
