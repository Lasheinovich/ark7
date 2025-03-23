from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_Health():
    return {"message": "Health Route"}
