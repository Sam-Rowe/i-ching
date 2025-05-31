# I-Ching Library NPM Dependencies Upgrade Plan

## Current Dependencies Status
```
Package     Current   Latest    Risk Level   Strategy
-------     -------   ------    ----------   --------
lodash      4.17.4    4.17.21   🟢 LOW       Direct upgrade
seedrandom  2.4.3     3.0.5     🟡 MEDIUM    Careful upgrade + testing
mocha       3.4.2     11.5.0    🔴 HIGH      Migrate to Jest
expect      1.20.2    29.7.0    🔴 HIGH      Part of Jest migration
```

## Phase 1: Low-Risk Upgrades

### Step 1.1: Upgrade lodash
```bash
# Backup current state
git add . && git commit -m "Pre-upgrade checkpoint: All 57 tests passing"

# Check current lodash usage in codebase
grep -r "lodash\|_\." lib/ test/ --include="*.js"

# Upgrade lodash
npm install lodash@4.17.21

# Run tests to verify compatibility
npm test

# If successful, commit
git add package*.json && git commit -m "Upgrade: lodash 4.17.4 → 4.17.21"
```

### Expected Result:
- ✅ Should pass without issues (patch version updates)
- ✅ All 57 tests should continue passing

## Phase 2: Medium-Risk Upgrades

### Step 2.1: Research seedrandom changes
```bash
# Check what's used in our codebase
grep -r "seedrandom" lib/ test/ --include="*.js"

# Check if 3.x has breaking changes
npm view seedrandom@3.0.5 | grep -E "(breaking|change|migration)"
```

### Step 2.2: Upgrade seedrandom
```bash
# Upgrade seedrandom
npm install seedrandom@3.0.5

# Run tests
npm test

# Check specific functionality that uses randomization
node -e "
const iChing = require('./lib/i-ching.js');
// Test that readings still generate properly
for(let i = 0; i < 10; i++) {
  const reading = iChing.ask('test ' + i);
  console.log('Reading', i, ':', reading.hexagram.number, reading.change ? '→ ' + reading.change.to.number : 'no change');
}
"

# If successful, commit
git add package*.json && git commit -m "Upgrade: seedrandom 2.4.3 → 3.0.5"
```

### Expected Result:
- ⚠️ May require minor code adjustments
- ✅ All tests should pass after any necessary fixes

## Phase 3: High-Risk Upgrades (Testing Framework)

### Problem Analysis:
- `expect@29+` is now part of Jest ecosystem
- `mocha@11+` has significant API changes
- Current `expect@1.20.2` is very old (2016)

### Solution: Migrate to Jest

### Step 3.1: Create migration branch
```bash
git checkout -b upgrade-testing-framework
```

### Step 3.2: Install Jest
```bash
# Remove old testing dependencies
npm uninstall expect mocha

# Install Jest
npm install --save-dev jest@29.7.0
```

### Step 3.3: Update package.json
```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "jest": {
    "testEnvironment": "node",
    "testMatch": ["**/test/**/*.test.js"],
    "collectCoverageFrom": [
      "lib/**/*.js",
      "!lib/data.json"
    ]
  }
}
```

### Step 3.4: Update test syntax (if needed)
Most of our current `expect()` usage should be compatible, but check:

**Current syntax (should work):**
```javascript
expect(value).toBe(expected)
expect(value).toEqual(expected)
expect(value).toExist()
expect(func).toThrow()
```

**Potential changes needed:**
```javascript
// Old: expect(value).toExist()
// New: expect(value).toBeDefined()

// Old: expect(value).toNotExist()  
// New: expect(value).toBeUndefined()

// Old: expect(value).toNotBe(other)
// New: expect(value).not.toBe(other)
```

### Step 3.5: Test migration
```bash
# Run tests with Jest
npm test

# If syntax issues, update test files
# Focus on extended-coverage.test.js and i-ching.test.js
```

### Step 3.6: Merge if successful
```bash
# If all tests pass
git add . && git commit -m "Migrate testing framework: mocha+expect → Jest"
git checkout main
git merge upgrade-testing-framework
```

## Alternative Strategy: Conservative Upgrade

If Jest migration proves too complex, consider conservative upgrades:

```bash
# Upgrade to newer but not latest versions
npm install --save-dev mocha@^8.0.0 expect@^27.0.0

# These versions are more likely to be compatible
```

## Rollback Plan

At any point, if issues arise:

```bash
# Rollback to last known good state
git reset --hard HEAD~1

# Or rollback specific packages
npm install lodash@4.17.4 seedrandom@2.4.3 mocha@3.4.2 expect@1.20.2
```

## Verification Checklist

After each upgrade phase:

- [ ] All 57 tests pass
- [ ] No new npm security warnings
- [ ] Library functionality unchanged:
  ```bash
  node -e "
  const iChing = require('./lib/i-ching.js');
  console.log('Hexagram 1:', iChing.hexagram(1).names[0]);
  console.log('Reading test:', iChing.ask('test').hexagram.number);
  console.log('Graph generation:', Object.keys(iChing.asGraph()));
  "
  ```
- [ ] No console warnings or errors
- [ ] Package-lock.json updated appropriately

## Security Benefits

Current packages have known vulnerabilities:
- lodash 4.17.4 → 4.17.21 (fixes prototype pollution)
- mocha 3.4.2 → 11.5.0 (fixes various security issues)
- General dependency tree updates

## Success Metrics

After complete upgrade:
- ✅ All 57 tests passing
- ✅ No npm audit vulnerabilities
- ✅ Modern testing framework
- ✅ Updated dependencies with active maintenance
- ✅ Improved development experience
- ✅ Better CI/CD compatibility

## Timeline Estimate

- Phase 1 (lodash): 30 minutes
- Phase 2 (seedrandom): 1-2 hours
- Phase 3 (testing framework): 3-4 hours
- **Total**: Half day for complete upgrade
