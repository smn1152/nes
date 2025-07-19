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
