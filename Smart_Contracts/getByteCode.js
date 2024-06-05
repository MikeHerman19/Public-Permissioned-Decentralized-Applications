const fs = require('fs');
const path = require('path');

const buildDir = path.join(__dirname, 'build', 'contracts');

fs.readdir(buildDir, (err, files) => {
  if (err) {
    console.error('Fehler beim Lesen des Verzeichnisses:', err);
    return;
  }

  files.forEach(file => {
    const filePath = path.join(buildDir, file);
    const contract = require(filePath);
    
    const bytecode = contract.bytecode;

    // Die Länge des Bytecodes in Bytes
    const bytecodeSize = Buffer.byteLength(bytecode, 'utf8') / 2;

    console.log(`${file}: ${bytecodeSize} bytes`);
  });
});
