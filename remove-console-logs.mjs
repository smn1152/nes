import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const jsDir = path.join(__dirname, 'public', 'js');

function removeConsoleLogs(dir) {
    fs.readdirSync(dir).forEach(file => {
        const filePath = path.join(dir, file);
        if (fs.statSync(filePath).isDirectory()) {
            removeConsoleLogs(filePath);
        } else if (file.endsWith('.js')) {
            let content = fs.readFileSync(filePath, 'utf8');
            const newContent = content.replace(/console\.(log|warn|error|info)\([^)]*\);?/g, '');
            if (content !== newContent) {
                fs.writeFileSync(filePath, newContent);
                console.log(`✓ Processed: ${filePath}`);
            }
        }
    });
}

removeConsoleLogs(jsDir);
console.log('✨ Console logs removed successfully!');
