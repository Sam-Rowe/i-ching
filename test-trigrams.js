const iChing = require('./lib/i-ching.js');

console.log('=== Trigram Table ===');
for (let i = 1; i <= 8; i++) {
  const t = iChing.trigram(i);
  console.log(`T${i}: binary=${t.binary}, lines=[${t.lines.join(',')}]`);
}

console.log('\n=== Hexagram 3 Detailed Analysis ===');
const h3 = iChing.hexagram(3);
console.log('H3 binary:', h3.binary);
console.log('H3 lines:', h3.lines);
console.log('H3 topTrigram number:', h3.topTrigram.number);
console.log('H3 topTrigram binary:', h3.topTrigram.binary);
console.log('H3 topTrigram lines:', h3.topTrigram.lines);
console.log('H3 bottomTrigram number:', h3.bottomTrigram.number);
console.log('H3 bottomTrigram binary:', h3.bottomTrigram.binary);
console.log('H3 bottomTrigram lines:', h3.bottomTrigram.lines);

console.log('\nH3 binary parts:');
console.log('  top part [0:3]:', h3.binary.slice(0, 3));
console.log('  bottom part [3:6]:', h3.binary.slice(3, 6));

console.log('\nComparison:');
console.log('  top trigram lines vs binary top:', h3.topTrigram.lines, 'vs', h3.binary.slice(0, 3).split('').map(Number));
console.log('  bottom trigram lines vs binary bottom:', h3.bottomTrigram.lines, 'vs', h3.binary.slice(3, 6).split('').map(Number));

// Check if trigram lines match their own binary
console.log('\nTrigram consistency:');
console.log('  top trigram binary matches lines:', h3.topTrigram.binary === h3.topTrigram.lines.join(''));
console.log('  bottom trigram binary matches lines:', h3.bottomTrigram.binary === h3.bottomTrigram.lines.join(''));
