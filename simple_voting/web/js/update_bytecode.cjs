const fs = require("fs");
const path = require("path");

const filename = 'bytecode.js';
const artifactPath = path.join(__dirname, "../../artifacts/contracts/SimpleVoting.sol/SimpleVoting.json");
const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));


let text = "";

text = 'const bytecode = "' + artifact.bytecode + '"; \n\n';
text += 'const abi = ' + JSON.stringify(artifact.abi) + '; \n\n';

text += "export { bytecode, abi };";

fs.writeFile(filename, text, 'utf8', (err) => {
    if (err) throw err;
    console.log('File saved!');
})