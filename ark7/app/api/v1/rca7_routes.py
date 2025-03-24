from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_Rca7():
    return {"message": "Rca7 Route"}
