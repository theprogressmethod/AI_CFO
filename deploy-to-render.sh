#!/bin/bash

echo "=== Render Deployment Setup ==="
echo ""
echo "This script will prepare your app for Render deployment"
echo ""

cd /Users/thomasmulhern/projects/AI_CFO

# Install dependencies including adapter-node
echo "1. Installing dependencies..."
npm uninstall @sveltejs/adapter-auto
npm install @sveltejs/adapter-node
npm install

# Build the app
echo ""
echo "2. Building the application..."
npm run build

echo ""
echo "3. Testing build locally..."
PORT=3000 npm start &
SERVER_PID=$!

sleep 3
echo ""
echo "App running at http://localhost:3000"
echo "Press Ctrl+C to stop and continue to deployment"
echo ""
read -p "Press Enter to continue to deployment..." 

kill $SERVER_PID 2>/dev/null

echo ""
echo "=== RENDER DEPLOYMENT INSTRUCTIONS ==="
echo ""
echo "OPTION 1: Deploy with GitHub (Recommended)"
echo "==========================================="
echo "1. Create a GitHub repository:"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial commit'"
echo "   git branch -M main"
echo "   git remote add origin https://github.com/YOUR_USERNAME/financial-processor.git"
echo "   git push -u origin main"
echo ""
echo "2. Go to https://dashboard.render.com"
echo "3. Click 'New +' → 'Web Service'"
echo "4. Connect your GitHub repo"
echo "5. Use these settings:"
echo "   - Name: financial-processor"
echo "   - Runtime: Docker"
echo "   - Branch: main"
echo "   - Root Directory: /"
echo "6. Click 'Create Web Service'"
echo ""
echo "OPTION 2: Deploy with Render CLI"
echo "================================="
echo "1. Install Render CLI:"
echo "   brew tap render-oss/render"
echo "   brew install render"
echo ""
echo "2. Login and deploy:"
echo "   render login"
echo "   render create"
echo "   render deploy"
echo ""
echo "Your app will be available at:"
echo "https://financial-processor.onrender.com"
echo ""
echo "Files are ready for deployment!"