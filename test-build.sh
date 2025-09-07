#!/bin/bash

echo "=== Testing Build Locally ==="
echo ""

cd /Users/thomasmulhern/projects/AI_CFO

# Clean install
echo "1. Clean installing dependencies..."
rm -rf node_modules package-lock.json build .svelte-kit
npm install

# Test build
echo ""
echo "2. Building application..."
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "3. Testing production build..."
    PORT=3000 npm start &
    SERVER_PID=$!
    
    sleep 3
    
    # Test if server is running
    if curl -s http://localhost:3000 > /dev/null; then
        echo "✅ Server is running successfully!"
        echo ""
        echo "Visit http://localhost:3000 to test"
        echo "Press Enter to stop the server and continue..."
        read
    else
        echo "❌ Server failed to start"
    fi
    
    kill $SERVER_PID 2>/dev/null
    
    echo ""
    echo "=== READY FOR DEPLOYMENT ==="
    echo ""
    echo "Now you can:"
    echo "1. Commit and push to GitHub:"
    echo "   git add ."
    echo "   git commit -m 'Fix Docker build configuration'"
    echo "   git push"
    echo ""
    echo "2. Render will automatically rebuild with the fixed Dockerfile"
else
    echo ""
    echo "❌ Build failed. Please check the error messages above."
    echo ""
    echo "Common issues:"
    echo "- Missing dependencies: Run 'npm install'"
    echo "- Missing config files: Check vite.config.js and svelte.config.js"
    echo "- TypeScript errors: Check for any .ts file issues"
fi