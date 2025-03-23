from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_rca7():
    response = client.get(f"/rca7")
    assert response.status_code == 200
    assert "Rca7 Route" in response.json().values()
