const fs = require("fs");
const path = require("path");

const filename = 'bytecode.js';
const artifactPath = path.join(__dirname, "../../artifacts/contracts/MyICO.sol/MyICO.json");
const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));


let text = "";

text = 'const ICObytecode = "' + artifact.bytecode + '"; \n\n';
text += 'const ICO_ABI = ' + JSON.stringify(artifact.abi) + '; \n\n';

text += "export { ICObytecode, ICO_ABI };";

fs.writeFile(filename, text, 'utf8', (err) => {
    if (err) throw err;
    console.log('File saved!');
})