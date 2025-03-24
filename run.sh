#!/bin/bash

set -e

PORT=8000

# 🛑 Free port if already in use
if lsof -i :$PORT &>/dev/null; then
  echo "⚠️ Port $PORT is already in use. Attempting to stop previous process..."
  PID=$(lsof -t -i:$PORT)
  sudo kill -9 $PID || true
  sleep 1
fi

### 0. Start
echo "🚀 Starting Ark7 Fullstack Deployment Script"

### 1. Check & Install Docker
echo "🐳 Checking Docker..."
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  sudo apt update && sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
fi

### 2. Build Docker Backend Image
echo "📦 Building Docker image for backend..."
docker build -t ark7-backend .

### 3. Run Docker Backend Container
echo "🚀 Running Docker container for backend..."
docker rm -f ark7-backend &>/dev/null || true
docker run -d --name ark7-backend -p $PORT:8080 ark7-backend || echo "⚠️ Docker container failed to start (check port conflict)."

### 4. Install Node.js, pnpm, and Corepack correctly
echo "📦 Installing Node.js, pnpm, and Corepack..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs jq
sudo npm install -g corepack
corepack enable

### 5. Safely Prepare and Activate pnpm
if ! command -v pnpm &> /dev/null; then
  corepack prepare pnpm@latest --activate || sudo npm install -g pnpm
fi

### 6. Clone and Setup Frontend (Next.js + Enhancements)
echo "🌐 Setting up frontend..."
if [ ! -d frontend ]; then
  pnpm create next-app@latest frontend -- --ts --tailwind --eslint --app --src-dir --import-alias "@/*"
fi
cd frontend
pnpm install || npm install

# UI/UX & DX enhancements
pnpm add -D prettier prettier-plugin-tailwindcss eslint-config-prettier framer-motion autoprefixer postcss@latest
pnpm add -D @tailwindcss/typography @tailwindcss/forms @tailwindcss/aspect-ratio
pnpm add -D @headlessui/react @radix-ui/react-icons @heroicons/react
pnpm add -D @chakra-ui/react @emotion/react @emotion/styled framer-motion
pnpm add -D shadcn/ui clsx lucide-react tailwind-variants zod react-hook-form @tanstack/react-query
pnpm add -D react-i18next i18next i18next-browser-languagedetector i18next-http-backend
pnpm add -D react-speech-recognition react-text-to-speech

mkdir -p public/locales/en public/locales/ar
cp ../i18n/en.json public/locales/en/translation.json || echo '{}' > public/locales/en/translation.json
cp ../i18n/ar.json public/locales/ar/translation.json || echo '{}' > public/locales/ar/translation.json

### 7. Create proxy to backend
echo "NEXT_PUBLIC_BACKEND_URL=http://localhost:$PORT" > .env.local

### 8. Build and serve frontend
pnpm build || npm run build
pnpm dlx serve -s out -l 3000 &
cd ..

### 9. Install Cloudflared
if ! command -v cloudflared &> /dev/null; then
  echo "☁️ Installing Cloudflared..."
  wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
  sudo dpkg -i cloudflared-linux-amd64.deb
fi

### 10. Login to Cloudflare
if [ ! -f ~/.cloudflared/cert.pem ]; then
  echo "🔐 Login to Cloudflare (browser opens)..."
  cloudflared tunnel login
fi

### 11. Create Tunnel if needed
if [ ! -f ~/.cloudflared/ce455010-2c5c-40a8-9c7b-31ca1d6578f3.json ]; then
  echo "🛠 Creating tunnel ark7-tunnel..."
  cloudflared tunnel create ark7-tunnel
fi

### 12. Write Cloudflare config.yml
CONFIG_FILE=~/.cloudflared/config.yml
cat <<EOF > $CONFIG_FILE
url: http://localhost:3000
tunnel: ce455010-2c5c-40a8-9c7b-31ca1d6578f3
credentials-file: /home/ark7/.cloudflared/ce455010-2c5c-40a8-9c7b-31ca1d6578f3.json
EOF

### 13. Route Domain (skip error if exists)
cloudflared tunnel route dns ce455010-2c5c-40a8-9c7b-31ca1d6578f3 globalarkacademy.org || echo "✅ DNS already set."

### 14. Run Tunnel
nohup cloudflared tunnel run ark7-tunnel > cloudflared.log 2>&1 &

### 15. RCA7 + AI + ML Enhancements
mkdir -p data uploads tmp app/learning/quran app/learning/hadith app/patterns app/knowledge_base
chmod -R 777 data uploads tmp

pip install --upgrade pip
pip install textract pandas openpyxl python-docx pypdf langdetect ffmpeg-python librosa \
  speechrecognition beautifulsoup4 scikit-learn xgboost catboost lightgbm \
  sentence-transformers transformers fastapi uvicorn keybert gensim \
  tiktoken faiss-cpu weaviate-client tesseract pillow pytesseract opencv-python \
  pyttsx3 gTTS pyaudio SpeechRecognition pocketsphinx moviepy imageio mediapipe \
  openai openai-whisper deepseek camel-tools qalsadi farasa arabicstopwords nltk \
  whoosh elasticsearch langchain-haystack prophet tslearn statsmodels huggingface-hub datasets \
  gradio streamlit dash fastapi-users sqlalchemy alembic databases passlib[bcrypt] python-jose[cryptography] \
  apscheduler python-crontab

### 16. Generate README.md
cat <<EOF > README.md
# 🌍 Ark7 AI Fullstack Platform

An AI-first universal system with Quranic/Hadith NLP, pattern recognition, and life-enhancing modules (RCA7).

Visit: https://globalarkacademy.org

## Features
- Quran & Hadith loader / pattern recognizer
- OCR, speech, image/audio/video processing
- Azure, Google, OpenAI, Deepseek integration
- CI/CD, Auth, Dashboards, SEO-ready frontend

## Run
```bash
bash run.sh  # Full deploy
```
EOF

echo "🎉 Deployment complete! Access it at: https://globalarkacademy.org"
echo "📄 Tunnel logs: tail -f cloudflared.log"
