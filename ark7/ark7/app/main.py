from fastapi import FastAPI
from app.api.v1 import routes

app = FastAPI(
    title="The Approach of Life API",
    description="Root Cause 7 + DDD Universal AI Framework",
    version="0.1.0"
)

app.include_router(routes.router)
