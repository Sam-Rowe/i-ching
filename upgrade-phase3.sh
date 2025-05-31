#!/bin/bash

# I-Ching NPM Dependencies Upgrade Script
# Phase 3: High-Risk Dependencies (Testing Framework Migration)

set -e  # Exit on any error

echo "🔧 I-Ching Dependencies Upgrade - Phase 3: Testing Framework"
echo "============================================================="

# Create migration branch
echo "🌿 Creating migration branch..."
git checkout -b upgrade-testing-framework

echo "📚 Current testing setup:"
npm list mocha expect

# Backup current test configuration
echo "💾 Backing up current test files..."
cp package.json package.json.backup
cp test/i-ching.test.js test/i-ching.test.js.backup 
cp test/extended-coverage.test.js test/extended-coverage.test.js.backup

# Remove old testing dependencies
echo "🗑️  Removing old testing dependencies..."
npm uninstall expect mocha

# Install Jest
echo "⬇️  Installing Jest..."
npm install --save-dev jest@29.7.0

# Update package.json scripts
echo "⚙️  Updating package.json scripts..."
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

pkg.scripts = {
  ...pkg.scripts,
  'test': 'jest',
  'test:watch': 'jest --watch', 
  'test:coverage': 'jest --coverage'
};

pkg.jest = {
  testEnvironment: 'node',
  testMatch: ['**/test/**/*.test.js'],
  collectCoverageFrom: [
    'lib/**/*.js',
    '!lib/data.json'
  ],
  verbose: true
};

fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
console.log('✅ Updated package.json with Jest configuration');
"

# Check if we need to update test syntax
echo "🔍 Checking test syntax compatibility..."
node -e "
const fs = require('fs');

const files = ['test/i-ching.test.js', 'test/extended-coverage.test.js'];
let needsUpdate = false;

files.forEach(file => {
  const content = fs.readFileSync(file, 'utf8');
  
  // Check for potentially incompatible syntax
  const issues = [];
  if (content.includes('.toExist()')) issues.push('toExist() → toBeDefined()');
  if (content.includes('.toNotExist()')) issues.push('toNotExist() → toBeUndefined()'); 
  if (content.includes('.toNotBe(')) issues.push('toNotBe() → not.toBe()');
  if (content.includes('.toNotEqual(')) issues.push('toNotEqual() → not.toEqual()');
  
  if (issues.length > 0) {
    console.log(\`⚠️  \${file} may need syntax updates:\`);
    issues.forEach(issue => console.log(\`   - \${issue}\`));
    needsUpdate = true;
  }
});

if (!needsUpdate) {
  console.log('✅ Test syntax appears to be Jest-compatible');
}
"

# Try running tests with Jest
echo "🧪 Testing Jest compatibility..."
if npm test; then
    echo "✅ All tests passed with Jest! Migration successful."
    
    # Show test coverage
    echo "📊 Generating test coverage report..."
    npm run test:coverage
    
    # Commit the migration
    git add . && git commit -m "Migrate testing framework: mocha+expect → Jest"
    
    # Merge back to main
    echo "🔄 Merging testing framework upgrade..."
    git checkout main
    git merge upgrade-testing-framework
    
    # Clean up backup files
    rm -f package.json.backup test/*.backup
    
    echo ""
    echo "🎉 Phase 3 Complete! Testing framework successfully migrated to Jest."
    echo ""
    echo "📦 Final package versions:"
    npm list --depth=0
    
    echo ""
    echo "✅ All upgrade phases completed successfully!"
    echo "🔒 Security status:"
    npm audit --audit-level=moderate || echo "Run 'npm audit' for detailed security info"
    
else
    echo "❌ Tests failed with Jest! Attempting syntax fixes..."
    
    # Try to auto-fix common syntax issues
    echo "🔧 Auto-fixing common Jest syntax issues..."
    
    for file in test/i-ching.test.js test/extended-coverage.test.js; do
        echo "Updating $file..."
        
        # Create backup
        cp "$file" "$file.jest-migration-backup"
        
        # Apply common fixes
        sed -i 's/\.toExist()/\.toBeDefined()/g' "$file"
        sed -i 's/\.toNotExist()/\.toBeUndefined()/g' "$file" 
        sed -i 's/\.toNotBe(/\.not.toBe(/g' "$file"
        sed -i 's/\.toNotEqual(/\.not.toEqual(/g' "$file"
        sed -i 's/expect(\([^)]*\))\.toNotThrow()/expect(\1).not.toThrow()/g' "$file"
    done
    
    echo "🧪 Re-testing with syntax fixes..."
    if npm test; then
        echo "✅ Tests passed after syntax fixes!"
        
        # Commit the fixed migration
        git add . && git commit -m "Migrate testing framework: mocha+expect → Jest (with syntax fixes)"
        
        # Merge back to main
        git checkout main
        git merge upgrade-testing-framework
        
        echo "🎉 Phase 3 Complete! Testing framework successfully migrated to Jest."
    else
        echo "❌ Tests still failing. Manual intervention required."
        echo "🔄 Rolling back to main branch..."
        git checkout main
        git branch -D upgrade-testing-framework
        
        echo "📝 Manual steps needed:"
        echo "1. Check Jest documentation for incompatible expect syntax"
        echo "2. Review test failures for specific issues"
        echo "3. Consider conservative upgrade approach instead"
        
        exit 1
    fi
fi
