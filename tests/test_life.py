from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_life():
    response = client.get(f"/life")
    assert response.status_code == 200
    assert "Life Route" in response.json().values()
