const fs = require('fs');
const path = require('path');

const jsDir = './public/js';

function removeConsoleLogs(dir) {
    fs.readdirSync(dir).forEach(file => {
        const filePath = path.join(dir, file);
        if (fs.statSync(filePath).isDirectory()) {
            removeConsoleLogs(filePath);
        } else if (file.endsWith('.js')) {
            let content = fs.readFileSync(filePath, 'utf8');
            content = content.replace(/console\.(log|warn|error|info)\([^)]*\);?/g, '');
            fs.writeFileSync(filePath, content);
            console.log(`Processed: ${filePath}`);
        }
    });
}

removeConsoleLogs(jsDir);
