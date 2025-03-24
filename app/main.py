from fastapi import FastAPI
from fastapi.responses import JSONResponse
import openai
import os

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Welcome to Global Ark Academy!"}

@app.post("/ai-tutor/")
async def ai_tutor(query: str):
    openai.api_key = os.getenv("OPENAI_API_KEY")
    response = openai.Completion.create(
        model="gpt-4",  # Ensure that you use the correct OpenAI model for tutoring
        prompt=query,
        max_tokens=150
    )
    return JSONResponse(content={"response": response.choices[0].text.strip()})
