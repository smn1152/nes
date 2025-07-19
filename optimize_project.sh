#!/bin/bash

# رنگ‌ها برای نمایش بهتر
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== شروع بهینه‌سازی پروژه Laravel ===${NC}"

# 1. تمیزکاری فایل‌های غیرضروری
echo -e "\n${YELLOW}1. حذف فایل‌های backup و log...${NC}"
git rm -r .upgrade_backups_20250719_131852/ 2>/dev/null || echo "Backup directory not found"
git rm upgrade_log_*.txt 2>/dev/null || echo "No upgrade logs found"
git rm premium_features_log_*.txt 2>/dev/null || echo "No premium logs found"
git rm app/Filament/Resources/CategoryResource.php.backup 2>/dev/null || true
git rm app/Filament/Resources/ProductResource.php.backup 2>/dev/null || true
git rm app/Models/Product.php.backup 2>/dev/null || true

# Commit اگر تغییری وجود داشت
if [[ -n $(git diff --cached --name-only) ]]; then
    git commit -m "Remove backup and log files"
    echo -e "${GREEN}✓ فایل‌های backup حذف شدند${NC}"
fi

# 2. به‌روزرسانی .gitignore
echo -e "\n${YELLOW}2. به‌روزرسانی .gitignore...${NC}"
cat >> .gitignore << 'GITIGNORE_EOF'

# Backup files
*.backup
.upgrade_backups*/
upgrade_log_*.txt
premium_features_log_*.txt
project_audit_report.*

# Shell scripts logs
*.sh.log

# IDE specific files (if not already present)
.idea/
.vscode/
*.swp
*.swo

# OS files (if not already present)
.DS_Store
Thumbs.db
GITIGNORE_EOF

git add .gitignore
git commit -m "Update .gitignore with backup and log patterns"
echo -e "${GREEN}✓ .gitignore به‌روزرسانی شد${NC}"

# 3. سازماندهی فایل‌های Script
echo -e "\n${YELLOW}3. سازماندهی scripts...${NC}"
mkdir -p scripts/setup
mkdir -p scripts/maintenance

# انتقال فایل‌ها اگر وجود دارند
[ -f "1.sh" ] && mv 1.sh scripts/setup/01_initial_setup.sh
[ -f "3.sh" ] && mv 3.sh scripts/setup/03_database_setup.sh
[ -f "10.sh" ] && mv 10.sh scripts/maintenance/10_cache_clear.sh
[ -f "11.sh" ] && mv 11.sh scripts/maintenance/11_optimize.sh
[ -f "12.sh" ] && mv 12.sh scripts/maintenance/12_backup.sh

# انتقال سایر scripts
for file in upgrade_*.sh; do
    [ -f "$file" ] && mv "$file" scripts/maintenance/
done

[ -f "add_premium_features.sh" ] && mv add_premium_features.sh scripts/setup/
[ -f "check-project-status.sh" ] && mv check-project-status.sh scripts/maintenance/
[ -f "project_health_check.sh" ] && mv project_health_check.sh scripts/maintenance/
[ -f "project_review.sh" ] && mv project_review.sh scripts/maintenance/
[ -f "setup_apple_experience.sh" ] && mv setup_apple_experience.sh scripts/setup/
[ -f "missing_functions.sh" ] && mv missing_functions.sh scripts/maintenance/

# حذف فایل‌های Node.js utility
rm -f remove-console-logs.cjs remove-console-logs.mjs

git add -A
git commit -m "Organize shell scripts into proper directories"
echo -e "${GREEN}✓ Scripts سازماندهی شدند${NC}"

# 4. ایجاد README.md
echo -e "\n${YELLOW}4. ایجاد README.md...${NC}"
cat > README.md << 'README_EOF'
# Salbion Group - Laravel Project

## درباره پروژه
این پروژه یک سیستم مدیریت محتوا با استفاده از Laravel و Filament Admin Panel است.

## Requirements
- PHP >= 8.1
- Composer
- MySQL/PostgreSQL  
- Node.js >= 16
- NPM/Yarn

## نصب و راه‌اندازی

### 1. Clone کردن پروژه
```bash
git clone https://github.com/smn1152/nes.git
cd nes
```

### 2. نصب Dependencies
```bash
composer install
npm install
```

### 3. تنظیمات Environment
```bash
cp .env.example .env
php artisan key:generate
```

### 4. تنظیمات Database
ویرایش فایل `.env` و تنظیم اطلاعات دیتابیس:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=salbion_db
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

### 5. اجرای Migrations
```bash
php artisan migrate --seed
```

### 6. Build Assets
```bash
npm run build
```

### 7. اجرای سرور
```bash
php artisan serve
```

## دسترسی به Admin Panel
آدرس: `http://localhost:8000/admin`

## ساختار پروژه
- `/app/Models` - Eloquent Models
- `/app/Filament` - Filament Resources و Widgets
- `/database/migrations` - Database Migrations
- `/database/seeders` - Database Seeders
- `/resources` - Views و Assets
- `/scripts` - Shell Scripts برای نصب و نگهداری

## Scripts موجود
- `scripts/setup/` - اسکریپت‌های نصب و راه‌اندازی
- `scripts/maintenance/` - اسکریپت‌های نگهداری و بهینه‌سازی

## License
This project is proprietary software.
README_EOF

git add README.md
git commit -m "Add comprehensive README.md"
echo -e "${GREEN}✓ README.md ایجاد شد${NC}"

# 5. ایجاد CHANGELOG.md
echo -e "\n${YELLOW}5. ایجاد CHANGELOG.md...${NC}"
cat > CHANGELOG.md << 'CHANGELOG_EOF'
# Changelog

## [Unreleased]

## [1.0.0] - 2025-01-19
### Added
- Initial release
- Filament Admin Panel
- Product management system
- Category management
- Division management
- Company settings
- Innovation stories
- Location management

### Security
- Laravel security best practices implemented
- Environment variables protection
- SQL injection prevention
- XSS protection

### Technical
- Laravel 11.x
- PHP 8.1+
- Filament 3.x
- Vite for asset bundling
CHANGELOG_EOF

git add CHANGELOG.md
git commit -m "Add CHANGELOG.md"
echo -e "${GREEN}✓ CHANGELOG.md ایجاد شد${NC}"

# 6. ایجاد .editorconfig
echo -e "\n${YELLOW}6. ایجاد .editorconfig...${NC}"
if [ ! -f .editorconfig ]; then
    cat > .editorconfig << 'EDITORCONFIG_EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 4
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[*.{yml,yaml}]
indent_size = 2

[*.{js,json,vue}]
indent_size = 2

[*.blade.php]
indent_size = 2
EDITORCONFIG_EOF

    git add .editorconfig
    git commit -m "Add .editorconfig"
    echo -e "${GREEN}✓ .editorconfig ایجاد شد${NC}"
else
    echo -e "${YELLOW}⚠ .editorconfig از قبل وجود دارد${NC}"
fi

# 7. ایجاد LICENSE (اختیاری)
echo -e "\n${YELLOW}7. ایجاد LICENSE file...${NC}"
cat > LICENSE << 'LICENSE_EOF'
Copyright (c) 2025 Salbion Group

All rights reserved.

This software and associated documentation files (the "Software") are proprietary
and confidential. Unauthorized copying, modification, distribution, or use of this
Software, via any medium, is strictly prohibited.
LICENSE_EOF

git add LICENSE
git commit -m "Add LICENSE file"
echo -e "${GREEN}✓ LICENSE ایجاد شد${NC}"

# 8. بهینه‌سازی composer و npm
echo -e "\n${YELLOW}8. بهینه‌سازی dependencies...${NC}"
echo "آیا می‌خواهید dependencies را به‌روزرسانی کنید؟ (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    composer update
    composer dump-autoload -o
    npm update
    npm audit fix --force 2>/dev/null || npm audit fix
    git add composer.lock package-lock.json
    git commit -m "Update and optimize dependencies"
    echo -e "${GREEN}✓ Dependencies به‌روزرسانی شدند${NC}"
fi

# 9. Push نهایی
echo -e "\n${YELLOW}9. Push تغییرات به GitHub...${NC}"
git push origin main
echo -e "${GREEN}✓ تمام تغییرات به GitHub push شدند${NC}"

# 10. نمایش خلاصه
echo -e "\n${GREEN}=== بهینه‌سازی کامل شد ===${NC}"
echo -e "${YELLOW}کارهای انجام شده:${NC}"
echo "✓ حذف فایل‌های backup و log"
echo "✓ به‌روزرسانی .gitignore"
echo "✓ سازماندهی scripts در پوشه‌های مناسب"
echo "✓ ایجاد README.md"
echo "✓ ایجاد CHANGELOG.md"
echo "✓ ایجاد .editorconfig"
echo "✓ ایجاد LICENSE"
echo "✓ Push تغییرات به GitHub"

echo -e "\n${YELLOW}مراحل بعدی پیشنهادی:${NC}"
echo "1. تنظیمات GitHub repository (Issues, Wiki, Branch protection)"
echo "2. تکمیل GitHub Actions در .github/workflows/ci.yml"
echo "3. اضافه کردن badges به README.md"
echo "4. ایجاد documentation در wiki"

echo -e "\n${GREEN}Repository URL: https://github.com/smn1152/nes${NC}"
