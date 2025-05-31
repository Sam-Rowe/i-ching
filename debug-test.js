const iChing = require('./lib/i-ching.js');
const data = require('./lib/data.json');

console.log('=== Testing Data Consistency ===');
// Check if binary matches lines for first few hexagrams
for (let i = 0; i < 5; i++) {
  const hex = data.hexagrams[i];
  const linesJoined = hex.lines.join('');
  console.log(`H${hex.number}: binary=${hex.binary}, lines=${linesJoined}, match=${hex.binary === linesJoined}`);
}

console.log('\n=== Testing changeLines ===');
const h1 = iChing.hexagram(1);
console.log('H1 lines:', h1.lines);
console.log('H1 binary:', h1.binary);

try {
  // Test with invalid values
  h1.changeLines([1,0,2,0,1,0]);
  console.log('ERROR: Should have thrown for invalid line value 2');
} catch(e) {
  console.log('Correctly threw error for invalid line value:', e.message);
}

try {
  const change = h1.changeLines([1,0,0,0,0,0]);
  console.log('Change result:', {
    binary: change.binary,
    toBinary: change.to.binary,
    toNumber: change.to.number
  });
} catch(e) {
  console.log('Error in changeLines:', e.message);
}

console.log('\n=== Testing Trigram Position Validation ===');
const t1 = iChing.trigram(1);
try {
  t1.hexagrams('invalid');
  console.log('ERROR: Should have thrown for invalid position');
} catch(e) {
  console.log('Correctly threw error for invalid position:', e.message);
}
