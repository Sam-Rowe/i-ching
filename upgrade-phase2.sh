#!/bin/bash

# I-Ching NPM Dependencies Upgrade Script  
# Phase 2: Medium-Risk Dependencies (seedrandom)

set -e  # Exit on any error

echo "🔧 I-Ching Dependencies Upgrade - Phase 2: seedrandom"
echo "====================================================="

# Check current seedrandom usage
echo "🔍 Analyzing current seedrandom usage..."
echo "Current seedrandom version:"
npm list seedrandom

echo "Seedrandom usage in codebase:"
grep -r "seedrandom" lib/ test/ --include="*.js" || echo "No direct seedrandom usage found"

# Research breaking changes
echo "📚 Checking for breaking changes..."
npm view seedrandom@3.0.5 --json | jq '.description, .version' || echo "Using npm view instead"
npm view seedrandom@3.0.5 | head -20

# Upgrade seedrandom
echo "⬆️  Upgrading seedrandom..."
npm install seedrandom@3.0.5

# Run comprehensive tests
echo "🧪 Running all 57 tests..."
if npm test; then
    echo "✅ Basic tests passed!"
    
    # Test randomization functionality specifically
    echo "🎲 Testing randomization functionality..."
    node -e "
    const iChing = require('./lib/i-ching.js');
    console.log('Testing random readings generation...');
    const readings = [];
    for(let i = 0; i < 10; i++) {
      const reading = iChing.ask('test question ' + i);
      readings.push({
        hex: reading.hexagram.number,
        change: reading.change ? reading.change.to.number : null
      });
      console.log(\`Reading \${i+1}: H\${reading.hexagram.number} \${reading.change ? '→ H' + reading.change.to.number : '(no change)'}\`);
    }
    
    // Verify we get some variety (not all the same)
    const hexNumbers = readings.map(r => r.hex);
    const uniqueHex = [...new Set(hexNumbers)];
    console.log(\`Generated \${uniqueHex.length} unique hexagrams out of 10 readings\`);
    
    if (uniqueHex.length < 2) {
      console.error('❌ Randomization may be broken - all readings are too similar');
      process.exit(1);
    } else {
      console.log('✅ Randomization appears to be working correctly');
    }
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Randomization tests passed! seedrandom upgrade successful."
        
        # Commit upgrade
        git add package*.json && git commit -m "Upgrade: seedrandom 2.4.3 → 3.0.5"
        
        echo "📦 Updated package versions:"
        npm list seedrandom
        
        echo ""
        echo "🎉 Phase 2 Complete! seedrandom successfully upgraded."
        echo "Next: Run ./upgrade-phase3.sh for testing framework migration"
    else
        echo "❌ Randomization tests failed!"
        exit 1
    fi
else
    echo "❌ Tests failed! Rolling back seedrandom upgrade..."
    npm install seedrandom@2.4.3
    echo "🔄 Rollback complete. Please investigate test failures."
    exit 1
fi
