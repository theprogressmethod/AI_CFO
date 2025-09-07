#!/bin/bash

# Initialize git and push to GitHub
echo "🚀 Initializing Git and pushing to GitHub..."

cd /Users/thomasmulhern/projects/AI_CFO

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    git init
    echo "✅ Git initialized"
else
    echo "✅ Git already initialized"
fi

# Add GitHub remote
git remote remove origin 2>/dev/null
git remote add origin https://github.com/theprogressmethod/AI_CFO.git
echo "✅ GitHub remote added"

# Create or update .gitignore
cat > .gitignore << 'EOF'
# Node modules
node_modules/
.npm

# Build outputs
.svelte-kit/
build/
dist/

# Environment files
.env
.env.local
.env.*.local

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Package manager files
package-lock.json
yarn.lock
pnpm-lock.yaml

# n8n data
.n8n/
n8n-data/

# Docker volumes
docker-data/
postgres-data/

# Temporary files
*.tmp
temp/
tmp/
EOF

echo "✅ .gitignore updated"

# Stage all files
git add .
echo "✅ Files staged"

# Commit
git commit -m "feat: Add table display for processed financial data

- Updated +page.svelte with improved table display component
- Added CSV export functionality for processed results
- Enhanced UI with status messages and error handling
- Improved CSS with table styling and responsive design
- Added connection test functionality
- Ready for n8n workflow integration"

echo "✅ Changes committed"

# Push to GitHub
git branch -M main
git push -u origin main
echo "✅ Pushed to GitHub"

echo ""
echo "📦 Repository: https://github.com/theprogressmethod/AI_CFO"
echo ""
echo "🔄 Hot reload should trigger automatically if dev server is running"
echo "If not, restart the dev server with: npm run dev"