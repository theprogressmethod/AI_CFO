#!/bin/bash

echo "=== Financial Processor Setup ==="
echo ""
echo "This will set up the client-side Excel processing solution"
echo ""

# Install dependencies
echo "1. Installing dependencies..."
cd /Users/thomasmulhern/projects/AI_CFO
npm install

echo ""
echo "2. Starting the application..."
echo ""
echo "The app will now process Excel files directly in the browser!"
echo "No n8n required for basic processing."
echo ""
echo "Opening in browser..."
npm run dev &

sleep 3
open http://localhost:5173

echo ""
echo "=== Setup Complete ==="
echo ""
echo "The application is now running and will:"
echo "✅ Read Excel files directly in the browser"
echo "✅ Process Income Statements and Balance Sheets"
echo "✅ Generate standardized 8-column output"
echo "✅ Download results as CSV or Excel"
echo ""
echo "No n8n workflow needed - everything runs client-side!"
echo ""
echo "To use with n8n (optional):"
echo "1. Import n8n-workflow-passthrough.json"
echo "2. Activate the workflow"
echo "3. Uncomment the n8n code in +page.svelte"