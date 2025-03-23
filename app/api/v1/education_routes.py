from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_Education():
    return {"message": "Education Route"}
