#!/bin/bash

echo "=== Fixing Dependencies and Starting App ==="
echo ""

cd /Users/thomasmulhern/projects/AI_CFO

# Clean install
echo "1. Cleaning node_modules and reinstalling..."
rm -rf node_modules package-lock.json
npm install

echo ""
echo "2. Installing Excel processing dependencies..."
npm install papaparse xlsx

echo ""
echo "3. Starting development server..."
npm run dev