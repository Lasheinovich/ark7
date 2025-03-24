from fastapi import FastAPI
from app.api.v1.routes import router

app = FastAPI()

# Include the API router
app.include_router(router)

# ✅ Root route for quick check
@app.get("/")
def root():
    return {"message": "🌍 Ark7 API is running!"}
