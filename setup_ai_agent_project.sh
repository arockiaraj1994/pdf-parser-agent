#!/bin/bash

echo "🧠 AI Agent Project Setup"

# Current working directory
PROJECT_PATH=$(pwd)

# Ask the project type
echo "Select the project type:"
echo "1. simple  (agents, knowledge, memory)"
echo "2. medium  (agents, knowledge, memory, configs)"
echo "3. full    (full setup with skills, planning, workflows, etc.)"

read -p "Enter your choice (1/2/3): " PROJECT_TYPE

# Function to create sample files inside a directory
create_sample_file() {
    local dir_path="$1"
    local file_name="$2"
    local content="$3"
    mkdir -p "$dir_path"
    echo -e "$content" > "$dir_path/$file_name"
}

# Create directories based on project type
case $PROJECT_TYPE in
  1)
    echo "⚡ Creating Simple Project Structure..."
    mkdir -p "$PROJECT_PATH/agents" "$PROJECT_PATH/memory"
    mkdir -p "$PROJECT_PATH/knowledge/pdf" "$PROJECT_PATH/knowledge/txt" "$PROJECT_PATH/knowledge/csv"
    ;;
  2)
    echo "⚡ Creating Medium Project Structure..."
    mkdir -p "$PROJECT_PATH/agents" "$PROJECT_PATH/memory" "$PROJECT_PATH/configs"
    mkdir -p "$PROJECT_PATH/knowledge/pdf" "$PROJECT_PATH/knowledge/txt" "$PROJECT_PATH/knowledge/csv"
    ;;
  3)
    echo "⚡ Creating Full Project Structure..."
    mkdir -p "$PROJECT_PATH/agents" "$PROJECT_PATH/skills" "$PROJECT_PATH/memory" "$PROJECT_PATH/llm" \
             "$PROJECT_PATH/planning" "$PROJECT_PATH/workflows" "$PROJECT_PATH/configs" \
             "$PROJECT_PATH/utils" "$PROJECT_PATH/tests" "$PROJECT_PATH/cli" "$PROJECT_PATH/notebooks"
    mkdir -p "$PROJECT_PATH/knowledge/pdf" "$PROJECT_PATH/knowledge/txt" "$PROJECT_PATH/knowledge/csv"
    ;;
  *)
    echo "❌ Invalid choice. Exiting."
    exit 1
    ;;
esac

# Add sample files
echo "📝 Adding sample files..."

create_sample_file "$PROJECT_PATH/agents" "sample_agent.py" "# Sample Agent\n\nclass SampleAgent:\n    pass"
create_sample_file "$PROJECT_PATH/memory" "memory_notes.txt" "# Memory system stores retrieved knowledge."

create_sample_file "$PROJECT_PATH/knowledge/pdf" "example.pdf" "This is a placeholder for PDFs."
create_sample_file "$PROJECT_PATH/knowledge/txt" "example.txt" "This is a sample TXT knowledge file."
create_sample_file "$PROJECT_PATH/knowledge/csv" "example.csv" "id,name,knowledge\n1,Sample,Knowledge Base"

if [ "$PROJECT_TYPE" -ge 2 ]; then
    create_sample_file "$PROJECT_PATH/configs" "settings.yaml" "# YAML configuration for the agent."
fi

if [ "$PROJECT_TYPE" -eq 3 ]; then
    create_sample_file "$PROJECT_PATH/skills" "sample_skill.py" "# Sample skill module."
    create_sample_file "$PROJECT_PATH/llm" "llm_client.py" "# LLM client wrapper."
    create_sample_file "$PROJECT_PATH/planning" "planner.py" "# Task planning logic."
    create_sample_file "$PROJECT_PATH/workflows" "workflow_runner.py" "# Run different agent workflows."
    create_sample_file "$PROJECT_PATH/utils" "helpers.py" "# Utility helper functions."
    create_sample_file "$PROJECT_PATH/tests" "test_sample.py" "# Tests for agent behaviors."
    create_sample_file "$PROJECT_PATH/cli" "run_agent.py" "# CLI to start the agent."
    create_sample_file "$PROJECT_PATH/notebooks" "README.md" "# Jupyter notebooks for exploration."
fi

# 🛠 Create simple requirements.txt
echo "📝 Creating requirements.txt..."

cat <<EOL > "$PROJECT_PATH/requirements.txt"
requests
pydantic
EOL

echo "✅ Project structure and requirements.txt created successfully inside: $PROJECT_PATH"

# 🐍 Setup Python Virtual Environment
echo "⚙️ Setting up Python Virtual Environment..."

cd "$PROJECT_PATH"

python3 -m virtualenv venv

echo "✅ Virtual environment created at: $PROJECT_PATH/venv"

echo ""
echo "👉 To activate the virtual environment, run:"
echo "source venv/bin/activate"
echo ""
echo "📦 Then install requirements by running:"
echo "pip install -r requirements.txt"
echo ""

# 🛠 GitHub setup (optional)
read -p "❓ Do you want to proceed with GitHub setup? (y/n): " GIT_SETUP

if [ "$GIT_SETUP" = "y" ] || [ "$GIT_SETUP" = "Y" ]; then
    if ! command -v git >/dev/null 2>&1; then
        echo "❌ Git is not installed. Please install Git first."
        exit 1
    fi

    echo "🛠 Initializing Git repository..."

    git init

    # Create a .gitignore
    echo "📝 Creating .gitignore..."
    cat <<EOL > .gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# Virtual environment
venv/
.env

# Jupyter Notebook checkpoints
.ipynb_checkpoints/

# VS Code settings
.vscode/

# Mac system files
.DS_Store
EOL

    git add .
    git commit -m "Initial commit"

    # Ask user for GitHub repo URL
    read -p "🔗 Enter your GitHub repository URL (example: https://github.com/username/repo.git): " REPO_URL

    if [ -z "$REPO_URL" ]; then
        echo "❌ No GitHub repo URL entered. Skipping remote setup."
    else
        git branch -M main
        git remote add origin "$REPO_URL"
        git push -u origin main
        echo "✅ Code pushed successfully to $REPO_URL"
    fi
else
    echo "⏩ Skipping GitHub setup."
fi

echo "🎉 Project setup complete!"
