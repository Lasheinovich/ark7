#!/bin/bash

# Step 1: Project root
mkdir -p ark7/app/{core,api,v1,models,services,schemas,utils} ark7/tests
cd ark7

# Step 2: Create base files
touch app/__init__.py \
      app/core/config.py \
      app/api/__init__.py \
      app/api/v1/__init__.py \
      app/main.py \
      app/models/__init__.py \
      app/services/__init__.py \
      app/schemas/__init__.py \
      app/utils/__init__.py \
      tests/__init__.py

# Step 3: Create requirements from working env
pip freeze > requirements.txt

# Step 4: Create example FastAPI entrypoint
cat <<EOF > app/main.py
from fastapi import FastAPI
from app.api.v1 import routes

app = FastAPI(
    title="The Approach of Life API",
    description="Root Cause 7 + DDD Universal AI Framework",
    version="0.1.0"
)

app.include_router(routes.router)
EOF

# Step 5: Add basic router setup
cat <<EOF > app/api/v1/routes.py
from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def read_root():
    return {"message": "Welcome to The Approach of Life 🌍 powered by RCA7 + DDD"}
EOF

# Step 6: Create run script
cat <<EOF > run.sh
#!/bin/bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
EOF
chmod +x run.sh

# Step 7: Finish
echo "✅ Ark7 project structure created successfully."
echo "➡️ To run your app: ./run.sh"
