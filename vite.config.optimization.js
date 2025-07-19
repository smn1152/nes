import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
    build: {
        minify: 'terser',
        terserOptions: {
            compress: {
                drop_console: true,
                drop_debugger: true
            }
        },
        rollupOptions: {
            output: {
                manualChunks: {
                    'markdown-editor': ['public/js/filament/forms/components/markdown-editor.js'],
                    'rich-editor': ['public/js/filament/forms/components/rich-editor.js'],
                    'file-upload': ['public/js/filament/forms/components/file-upload.js']
                }
            }
        }
    }
});
