# Misctools Justfile
# Collection of commands for building and installing miscellaneous tools

# Default recipe lists available commands
default:
    @just --list

# Install all tools by iterating through directories and running build/install scripts
install-all:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "🔧 Installing misctools..."
    
    # Find all directories (topics) excluding .git
    for dir in */; do
        # Skip if not a directory or if it's .git
        if [[ ! -d "$dir" || "$dir" == ".git/" ]]; then
            continue
        fi
        
        topic="${dir%/}"  # Remove trailing slash
        echo "📁 Processing $topic tools..."
        
        cd "$dir"
        
        # Run build script if it exists
        if [[ -f "build.sh" ]]; then
            echo "  🔨 Running build script for $topic..."
            chmod +x build.sh
            ./build.sh
        fi
        
        # Run install script if it exists
        if [[ -f "install.sh" ]]; then
            echo "  📦 Running install script for $topic..."
            chmod +x install.sh
            ./install.sh
        else
            # Fallback: make all .sh files executable and suggest manual installation
            echo "  ⚙️  Making scripts executable in $topic..."
            chmod +x *.sh 2>/dev/null || true
            echo "  💡 No install script found. Scripts are now executable."
            echo "     You can manually symlink them to your PATH, e.g.:"
            for script in *.sh; do
                if [[ -f "$script" ]]; then
                    script_name="${script%.sh}"
                    echo "       ln -s \$(pwd)/$script /usr/local/bin/$script_name"
                fi
            done
        fi
        
        cd ..
        echo "  ✅ Finished processing $topic"
        echo
    done
    
    echo "🎉 All tools processed!"

# Clean build artifacts (if any build scripts create them)
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "🧹 Cleaning build artifacts..."
    
    for dir in */; do
        if [[ ! -d "$dir" || "$dir" == ".git/" ]]; then
            continue
        fi
        
        cd "$dir"
        
        # Run clean script if it exists
        if [[ -f "clean.sh" ]]; then
            echo "  🗑️  Running clean script for ${dir%/}..."
            chmod +x clean.sh
            ./clean.sh
        fi
        
        cd ..
    done
    
    echo "✨ Cleanup complete!"

# List all available tools across all topics
list-tools:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "📋 Available tools:"
    echo
    
    for dir in */; do
        if [[ ! -d "$dir" || "$dir" == ".git/" ]]; then
            continue
        fi
        
        topic="${dir%/}"
        echo "📁 $topic:"
        
        cd "$dir"
        for script in *.sh; do
            if [[ -f "$script" ]]; then
                # Extract first comment line as description if available
                description=$(head -5 "$script" | grep -E '^#[^!]' | head -1 | sed 's/^# *//' || echo "")
                if [[ -n "$description" ]]; then
                    echo "  • $script - $description"
                else
                    echo "  • $script"
                fi
            fi
        done
        cd ..
        echo
    done

# Check tool dependencies and health
check:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "🔍 Checking tool dependencies..."
    echo
    
    # Check common dependencies
    echo "Common tools:"
    for tool in bash jq curl wget; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool (not found)"
        fi
    done
    echo
    
    # Check topic-specific dependencies
    if [[ -d "aws/" ]]; then
        echo "AWS tools:"
        for tool in aws docker; do
            if command -v "$tool" >/dev/null 2>&1; then
                echo "  ✅ $tool"
            else
                echo "  ❌ $tool (not found)"
            fi
        done
        echo
    fi
    
    echo "🏥 Health check complete!"
