from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_financial():
    response = client.get(f"/financial")
    assert response.status_code == 200
    assert "Financial Route" in response.json().values()
