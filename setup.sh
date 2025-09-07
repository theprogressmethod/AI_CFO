#!/bin/bash

echo "🚀 AI CFO - Initial Setup"
echo "========================"
echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "✅ .env file created"
    echo ""
    echo "⚠️  Please edit .env and add your n8n webhook URL:"
    echo "   - For local n8n: http://localhost:5678/webhook/process-financials"
    echo "   - For cloud n8n: https://your-instance.app.n8n.cloud/webhook/process-financials"
    echo ""
else
    echo "✅ .env file already exists"
    echo ""
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
    echo ""
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Instructions for n8n setup
echo "📋 Next Steps:"
echo "============="
echo ""
echo "1. Set up n8n workflow:"
echo "   - Install n8n: npm install -g n8n"
echo "   - Start n8n: n8n start"
echo "   - Import workflow: n8n-financial-workflow.json"
echo "   - Add your OpenAI API key to the AI Transform node"
echo "   - Activate the workflow"
echo ""
echo "2. Configure the web app:"
echo "   - Edit .env file with your n8n webhook URL"
echo ""
echo "3. Run the application:"
echo "   - Development: npm run dev"
echo "   - Production: npm run deploy"
echo ""
echo "📚 Full documentation: README.md"
echo ""
echo "✅ Setup complete! Run 'npm run dev' to start the application."
