from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_Governance():
    return {"message": "Governance Route"}
