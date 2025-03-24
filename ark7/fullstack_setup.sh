#!/bin/bash

set -e

# --- Step 1: Set Node.js Memory Limit ---
export NODE_OPTIONS="--max-old-space-size=8192"  # 8GB of memory
echo "✅ Node.js memory limit set to 8GB."

# --- Step 2: Backend Docker Setup ---
echo "🚀 Starting backend container..."
docker start ark7-backend || docker run -d --name ark7-backend -p 8080:8080 ark7-backend
echo "✅ Backend container started."

# --- Step 3: Cloudflare Tunnel Setup ---
if [ ! -f "~/.cloudflared/cert.pem" ]; then
  echo "🔐 No Cloudflare cert found, attempting login..."
  mv ~/.cloudflared/cert.pem ~/.cloudflared/cert.pem.bak
  cloudflared tunnel login
  echo "✅ Successfully logged into Cloudflare. Credentials saved."
else
  echo "🔐 Cloudflare certificate already exists. Skipping login."
fi

# --- Step 4: Run Cloudflare Tunnel ---
echo "🌐 Starting Cloudflare tunnel..."
cloudflared tunnel run &
echo "Cloudflare Tunnel running..."

# --- Step 5: Frontend Setup and Optimization ---
echo "🔧 Navigating to frontend directory..."
cd ~/ark7/frontend

# Clean previous build artifacts and reinstall dependencies
echo "🧹 Cleaning Next.js cache and node_modules..."
rm -rf .next node_modules

# Install dependencies using pnpm
echo "📦 Reinstalling dependencies using pnpm..."
pnpm install

# Enable persistent caching and disable TypeScript type checking
echo "Enabling persistent caching..."
echo "NEXT_WEBPACK5=true" >> .env.local
echo "NEXT_CACHE=true" >> .env.local
echo "DISABLE_TSCHECK=true" >> .env.local

# --- Step 6: Build the Frontend ---
echo "⚡ Building frontend application..."
pnpm build

# --- Step 7: Start Frontend Development Server ---
echo "🚀 Starting frontend server on http://localhost:3000"
pnpm dev

# --- Step 8: Fullstack Deployment ---
echo "🛠 Checking backend and frontend services..."

# Ensure backend and frontend are running
docker ps | grep ark7-backend || docker run -d --name ark7-backend -p 8080:8080 ark7-backend

echo "✅ Fullstack environment is running:"
echo "Frontend: http://localhost:3000"
echo "Backend: http://localhost:8080"

# --- Step 9: Health Check for Backend ---
if ! curl -s http://localhost:8080/health; then
  echo "❌ Backend service not accessible. Please check Docker and Cloudflare Tunnel setup."
else
  echo "✅ Backend service running successfully."
fi

# --- Step 10: Monitoring Resources ---
echo "💻 Monitoring system resources during build and run..."
top &  # Replacing htop for more lightweight monitoring

# Final Check for Frontend
if ! curl -s http://localhost:3000; then
  echo "❌ Frontend service not accessible."
else
  echo "✅ Frontend service running successfully."
fi

# Keep script running
tail -f /dev/null
