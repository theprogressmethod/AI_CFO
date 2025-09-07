import subprocess
import json
import os
import time
import webbrowser
from pathlib import Path

# Colors for terminal output
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

def run_command(cmd, cwd=None):
    """Run a shell command and return the result."""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=cwd)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def main():
    print(f"{BLUE}🚀 AI CFO - Automated Launch Script{NC}")
    print("=" * 40)
    print()
    
    project_dir = "/Users/thomasmulhern/projects/AI_CFO"
    os.chdir(project_dir)
    
    # Step 1: Install dependencies
    print(f"{BLUE}📦 Installing dependencies...{NC}")
    success, _, _ = run_command("npm install")
    if not success:
        print(f"{RED}❌ Failed to install dependencies{NC}")
        return
    print(f"{GREEN}✅ Dependencies installed{NC}\n")
    
    # Step 2: Build the project
    print(f"{BLUE}🔨 Building the project...{NC}")
    success, _, _ = run_command("npm run build")
    if not success:
        print(f"{RED}❌ Build failed{NC}")
        return
    print(f"{GREEN}✅ Build successful!{NC}\n")
    
    # Step 3: Initialize Git
    print(f"{BLUE}📝 Initializing Git repository...{NC}")
    if not os.path.exists(".git"):
        run_command("git init")
        run_command("git add .")
        run_command('git commit -m "Initial commit - AI CFO Financial Processor"')
        print(f"{GREEN}✅ Git repository initialized{NC}\n")
    else:
        run_command("git add .")
        run_command('git commit -m "Update AI CFO"')
        print(f"{GREEN}✅ Git repository updated{NC}\n")
    
    # Step 4: Start local server
    print(f"{BLUE}🖥️  Starting local development server...{NC}")
    dev_process = subprocess.Popen(["npm", "run", "dev"], 
                                   stdout=subprocess.PIPE, 
                                   stderr=subprocess.PIPE)
    
    # Wait a moment for server to start
    time.sleep(3)
    
    # Open browser
    webbrowser.open("http://localhost:5173")
    print(f"{GREEN}✅ Local server started at: http://localhost:5173{NC}\n")
    
    # Display instructions
    print("=" * 60)
    print(f"{GREEN}✅ LOCAL SETUP COMPLETE!{NC}")
    print("=" * 60)
    print()
    print(f"{YELLOW}📋 QUICK DEPLOYMENT STEPS:{NC}")
    print()
    print("1️⃣  Create GitHub Repository:")
    print(f"{BLUE}   Click here: https://github.com/new{NC}")
    print("   • Name: ai-cfo-financial-processor")
    print("   • Private repository")
    print("   • Don't initialize with README")
    print()
    print("2️⃣  Push to GitHub (copy & paste these commands):")
    print(f"{GREEN}")
    print("git remote add origin https://github.com/[YOUR_USERNAME]/ai-cfo-financial-processor.git")
    print("git push -u origin main")
    print(f"{NC}")
    print()
    print("3️⃣  Deploy to Render:")
    print(f"{BLUE}   Click here: https://dashboard.render.com/new/static{NC}")
    print("   • Connect your GitHub repo")
    print("   • It will auto-configure from render.yaml")
    print("   • Click 'Create Static Site'")
    print()
    print("4️⃣  Activate n8n Workflow:")
    print(f"{BLUE}   Go to: https://app.n8n.cloud{NC}")
    print("   • Import: n8n-financial-workflow.json")
    print("   • Add your OpenAI API key")
    print("   • Activate the workflow")
    print()
    print("=" * 60)
    print(f"{GREEN}Your app is now running locally!{NC}")
    print("Test it with your financial statements.")
    print()
    print(f"{YELLOW}Press Ctrl+C to stop the local server{NC}")
    
    try:
        # Keep the server running
        dev_process.wait()
    except KeyboardInterrupt:
        print(f"\n{YELLOW}Stopping local server...{NC}")
        dev_process.terminate()
        print(f"{GREEN}✅ Server stopped{NC}")

if __name__ == "__main__":
    main()
