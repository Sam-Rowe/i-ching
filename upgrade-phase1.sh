#!/bin/bash

# I-Ching NPM Dependencies Upgrade Script
# Phase 1: Low-Risk Dependencies (lodash)

set -e  # Exit on any error

echo "🔧 I-Ching Dependencies Upgrade - Phase 1: lodash"
echo "================================================="

# Create checkpoint
echo "📸 Creating pre-upgrade checkpoint..."
git add . && git commit -m "Pre-upgrade checkpoint: All 57 tests passing" || echo "Nothing to commit"

# Check current lodash usage
echo "🔍 Analyzing current lodash usage..."
echo "Current lodash version:"
npm list lodash

echo "Lodash usage in codebase:"
grep -r "lodash\|_\." lib/ test/ --include="*.js" || echo "No direct lodash usage found"

# Upgrade lodash
echo "⬆️  Upgrading lodash..."
npm install lodash@4.17.21

# Run tests
echo "🧪 Running all 57 tests..."
if npm test; then
    echo "✅ All tests passed! lodash upgrade successful."
    
    # Commit upgrade
    git add package*.json && git commit -m "Upgrade: lodash 4.17.4 → 4.17.21"
    
    echo "📦 Updated package versions:"
    npm list lodash
    
    echo ""
    echo "🎉 Phase 1 Complete! lodash successfully upgraded."
    echo "Next: Run ./upgrade-phase2.sh for seedrandom upgrade"
else
    echo "❌ Tests failed! Rolling back lodash upgrade..."
    npm install lodash@4.17.4
    echo "🔄 Rollback complete. Please investigate test failures."
    exit 1
fi
