from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_spiritual():
    response = client.get(f"/spiritual")
    assert response.status_code == 200
    assert "Spiritual Route" in response.json().values()
