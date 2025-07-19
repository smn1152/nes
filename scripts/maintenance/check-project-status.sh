#!/bin/bash

echo "🔍 بررسی وضعیت نهایی پروژه"
echo "================================"

echo -e "\n✅ Migrations:"
php artisan migrate:status | grep Pending | wc -l | xargs -I {} echo "   - Pending migrations: {}"

echo -e "\n✅ Tests:"
php artisan test --quiet 2>&1 | tail -1

echo -e "\n✅ Routes:"
echo -n "   - Total routes: "
php artisan route:list 2>/dev/null | tail -n +4 | wc -l
echo -n "   - API routes: "
php artisan route:list 2>/dev/null | grep "/api/" | wc -l

echo -e "\n✅ Security:"
echo -n "   - APP_DEBUG: "
grep "APP_DEBUG" .env | cut -d'=' -f2
echo -n "   - APP_ENV: "
grep "APP_ENV" .env | cut -d'=' -f2

echo -e "\n✅ NPM:"
npm audit 2>&1 | grep "found" | head -1 || echo "   - No vulnerabilities found"

echo -e "\n✅ Clean up:"
echo -n "   - Analyzer files: "
find . -name "*analyzer*.py" 2>/dev/null | wc -l
echo -n "   - Console logs in JS: "
grep -r "console\." public/js --include="*.js" 2>/dev/null | wc -l

echo -e "\n================================"
echo "✨ بررسی کامل شد!"
