from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_Financial():
    return {"message": "Financial Route"}
