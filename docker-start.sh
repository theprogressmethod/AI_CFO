#!/bin/bash

echo "🐳 AI CFO Docker Quick Start"
echo "============================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo "Please start Docker Desktop first"
    echo ""
    echo "Download from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ Environment loaded"
else
    echo "⚠️  Using default configuration"
    echo "VITE_N8N_WEBHOOK_URL=http://localhost:5678/webhook/process-financials" > .env
fi

# Quick menu
echo "Choose deployment mode:"
echo "1) 🚀 Production (optimized, port 3000)"
echo "2) 🔧 Development (hot reload, port 5173)"
echo ""
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        echo ""
        echo "🏗️  Building production image..."
        docker-compose build
        
        echo ""
        echo "🚀 Starting production services..."
        docker-compose up -d
        
        echo ""
        echo "✅ AI CFO is running!"
        echo ""
        echo "📍 Access points:"
        echo "   Web App: http://localhost:3000"
        echo "   n8n:     http://localhost:5678"
        echo ""
        echo "📋 Commands:"
        echo "   View logs:  docker-compose logs -f"
        echo "   Stop:       docker-compose down"
        echo "   Restart:    docker-compose restart"
        ;;
        
    2)
        echo ""
        echo "🏗️  Building development image..."
        docker-compose -f docker-compose.dev.yml build
        
        echo ""
        echo "🔧 Starting development services..."
        docker-compose -f docker-compose.dev.yml up -d
        
        echo ""
        echo "✅ AI CFO Development is running!"
        echo ""
        echo "📍 Access points:"
        echo "   Web App: http://localhost:5173 (with hot reload)"
        echo "   n8n:     http://localhost:5678"
        echo ""
        echo "📋 Commands:"
        echo "   View logs:  docker-compose -f docker-compose.dev.yml logs -f"
        echo "   Stop:       docker-compose -f docker-compose.dev.yml down"
        echo "   Restart:    docker-compose -f docker-compose.dev.yml restart"
        ;;
        
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎯 Next steps:"
echo "1. Import n8n workflow at http://localhost:5678"
echo "2. Upload workflow file: n8n-financial-workflow.json"
echo "3. Add OpenAI API key to the workflow"
echo "4. Activate the workflow"
echo "5. Test with your Excel files!"
