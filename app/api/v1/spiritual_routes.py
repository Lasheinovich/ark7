from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_Spiritual():
    return {"message": "Spiritual Route"}
