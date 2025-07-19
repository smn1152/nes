#!/bin/bash

# ==============================================
# Salbion Group Project Comprehensive Review
# Version: 1.0
# ==============================================

set -euo pipefail

# Colors
COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_CYAN='\033[0;36m'
COLOR_PURPLE='\033[0;35m'
COLOR_BLUE='\033[0;34m'
COLOR_BOLD='\033[1m'

# Initialize
PROJECT_ROOT="$(pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="$PROJECT_ROOT/project_review_$TIMESTAMP"
REPORT_FILE="$REPORT_DIR/review_report.md"
JSON_REPORT="$REPORT_DIR/review_report.json"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Create report directory
mkdir -p "$REPORT_DIR"

# Logging functions
log_message() {
    local type="$1"
    local message="$2"
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"
    
    case "$type" in
        "error")
            echo -e "${COLOR_RED}$timestamp ❌ ERROR: $message${COLOR_RESET}"
            ((FAILED_CHECKS++))
            ;;
        "warning")
            echo -e "${COLOR_YELLOW}$timestamp ⚠️  WARNING: $message${COLOR_RESET}"
            ((WARNINGS++))
            ;;
        "success")
            echo -e "${COLOR_GREEN}$timestamp ✅ SUCCESS: $message${COLOR_RESET}"
            ((PASSED_CHECKS++))
            ;;
        "info")
            echo -e "${COLOR_CYAN}$timestamp ℹ️  INFO: $message${COLOR_RESET}"
            ;;
        "header")
            echo -e "${COLOR_BOLD}\n================================"
            echo -e "🔍 $message"
            echo -e "================================${COLOR_RESET}"
            ;;
    esac
    
    ((TOTAL_CHECKS++))
}

# Start report
cat > "$REPORT_FILE" << 'REPORT_HEADER'
# Salbion Group Project Review Report

**Generated on:** $(date)
**Project Path:** $(pwd)

## Executive Summary

This comprehensive review analyzes your Laravel project across multiple dimensions including code quality, security, performance, best practices, and more.

---

REPORT_HEADER

# 1. Project Structure Analysis
analyze_project_structure() {
    log_message "header" "PROJECT STRUCTURE ANALYSIS"
    
    echo "## 1. Project Structure Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Count files by type
    local php_files=$(find . -name "*.php" -not -path "./vendor/*" -not -path "./node_modules/*" | wc -l)
    local blade_files=$(find . -name "*.blade.php" -not -path "./vendor/*" | wc -l)
    local js_files=$(find . -name "*.js" -not -path "./vendor/*" -not -path "./node_modules/*" | wc -l)
    local css_files=$(find . -name "*.css" -not -path "./vendor/*" -not -path "./node_modules/*" | wc -l)
    
    echo "### File Statistics" >> "$REPORT_FILE"
    echo "- PHP Files: $php_files" >> "$REPORT_FILE"
    echo "- Blade Templates: $blade_files" >> "$REPORT_FILE"
    echo "- JavaScript Files: $js_files" >> "$REPORT_FILE"
    echo "- CSS Files: $css_files" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    log_message "info" "PHP Files: $php_files"
    log_message "info" "Blade Templates: $blade_files"
    
    # Check directory structure
    echo "### Directory Structure" >> "$REPORT_FILE"
    tree -L 2 -d --charset=ascii 2>/dev/null >> "$REPORT_FILE" || echo "Tree command not available" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Check for required directories
    local required_dirs=("app" "config" "database" "public" "resources" "routes" "storage" "tests")
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_message "success" "Directory exists: $dir"
        else
            log_message "error" "Missing directory: $dir"
        fi
    done
}

# 2. Code Quality Analysis
analyze_code_quality() {
    log_message "header" "CODE QUALITY ANALYSIS"
    
    echo "## 2. Code Quality Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Install PHP Code Sniffer if not exists
    if ! command -v phpcs &> /dev/null; then
        log_message "info" "Installing PHP CodeSniffer..."
        composer global require "squizlabs/php_codesniffer=*" || true
    fi
    
    # Run PHP Code Sniffer
    if command -v phpcs &> /dev/null; then
        echo "### PHP Code Standards (PSR-12)" >> "$REPORT_FILE"
        phpcs --standard=PSR12 --report=summary app/ 2>&1 | tee -a "$REPORT_FILE" || true
        echo "" >> "$REPORT_FILE"
    fi
    
    # Check for common code issues
    echo "### Code Issues" >> "$REPORT_FILE"
    
    # Check for dd() statements
    local dd_count=$(grep -r "dd(" app/ --include="*.php" 2>/dev/null | wc -l || echo "0")
    if [[ $dd_count -gt 0 ]]; then
        log_message "warning" "Found $dd_count dd() statements in code"
        echo "- ⚠️ Found $dd_count dd() debug statements" >> "$REPORT_FILE"
    else
        log_message "success" "No dd() statements found"
        echo "- ✅ No dd() debug statements found" >> "$REPORT_FILE"
    fi
    
    # Check for var_dump
    local vardump_count=$(grep -r "var_dump(" app/ --include="*.php" 2>/dev/null | wc -l || echo "0")
    if [[ $vardump_count -gt 0 ]]; then
        log_message "warning" "Found $vardump_count var_dump() statements"
        echo "- ⚠️ Found $vardump_count var_dump() statements" >> "$REPORT_FILE"
    else
        log_message "success" "No var_dump() statements found"
        echo "- ✅ No var_dump() statements found" >> "$REPORT_FILE"
    fi
    
    # Check for console.log
    local console_count=$(grep -r "console.log" resources/ --include="*.js" --include="*.blade.php" 2>/dev/null | wc -l || echo "0")
    if [[ $console_count -gt 0 ]]; then
        log_message "warning" "Found $console_count console.log statements"
        echo "- ⚠️ Found $console_count console.log statements" >> "$REPORT_FILE"
    else
        log_message "success" "No console.log statements found"
        echo "- ✅ No console.log statements found" >> "$REPORT_FILE"
    fi
    
    echo "" >> "$REPORT_FILE"
}

# 3. Security Analysis
analyze_security() {
    log_message "header" "SECURITY ANALYSIS"
    
    echo "## 3. Security Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Check .env file
    if [[ -f .env ]]; then
        # Check APP_DEBUG
        if grep -q "APP_DEBUG=true" .env; then
            log_message "warning" "APP_DEBUG is set to true"
            echo "- ⚠️ APP_DEBUG is set to true (should be false in production)" >> "$REPORT_FILE"
        else
            log_message "success" "APP_DEBUG is properly set"
            echo "- ✅ APP_DEBUG is properly set" >> "$REPORT_FILE"
        fi
        
        # Check APP_KEY
        if grep -q "APP_KEY=base64:" .env; then
            log_message "success" "APP_KEY is set"
            echo "- ✅ APP_KEY is properly set" >> "$REPORT_FILE"
        else
            log_message "error" "APP_KEY is not set"
            echo "- ❌ APP_KEY is not set" >> "$REPORT_FILE"
        fi
    else
        log_message "error" ".env file not found"
        echo "- ❌ .env file not found" >> "$REPORT_FILE"
    fi
    
    # Check for security headers
    echo "" >> "$REPORT_FILE"
    echo "### Security Headers Check" >> "$REPORT_FILE"
    
    if [[ -f public/.htaccess ]]; then
        if grep -q "X-Frame-Options" public/.htaccess; then
            log_message "success" "X-Frame-Options header configured"
            echo "- ✅ X-Frame-Options header configured" >> "$REPORT_FILE"
        else
            log_message "warning" "X-Frame-Options header not configured"
            echo "- ⚠️ X-Frame-Options header not configured" >> "$REPORT_FILE"
        fi
    fi
    
    # Check file permissions
    echo "" >> "$REPORT_FILE"
    echo "### File Permissions" >> "$REPORT_FILE"
    
    # Check storage permissions
    if [[ -w storage ]]; then
        log_message "success" "Storage directory is writable"
        echo "- ✅ Storage directory is writable" >> "$REPORT_FILE"
    else
        log_message "error" "Storage directory is not writable"
        echo "- ❌ Storage directory is not writable" >> "$REPORT_FILE"
    fi
    
    # Check for exposed sensitive files
    local sensitive_files=(".env" ".env.example" "composer.json" "package.json")
    echo "" >> "$REPORT_FILE"
    echo "### Sensitive Files Check" >> "$REPORT_FILE"
    
    for file in "${sensitive_files[@]}"; do
        if [[ -f "public/$file" ]]; then
            log_message "error" "Sensitive file exposed in public: $file"
            echo "- ❌ Sensitive file exposed in public: $file" >> "$REPORT_FILE"
        fi
    done
    
    echo "" >> "$REPORT_FILE"
}

# 4. Performance Analysis
analyze_performance() {
    log_message "header" "PERFORMANCE ANALYSIS"
    
    echo "## 4. Performance Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Check cache configuration
    echo "### Cache Configuration" >> "$REPORT_FILE"
    
    if [[ -f bootstrap/cache/config.php ]]; then
        log_message "success" "Configuration is cached"
        echo "- ✅ Configuration is cached" >> "$REPORT_FILE"
    else
        log_message "warning" "Configuration is not cached"
        echo "- ⚠️ Configuration not cached (run: php artisan config:cache)" >> "$REPORT_FILE"
    fi
    
    if [[ -f bootstrap/cache/routes-v7.php ]]; then
        log_message "success" "Routes are cached"
        echo "- ✅ Routes are cached" >> "$REPORT_FILE"
    else
        log_message "warning" "Routes are not cached"
        echo "- ⚠️ Routes not cached (run: php artisan route:cache)" >> "$REPORT_FILE"
    fi
    
    # Check for N+1 queries
    echo "" >> "$REPORT_FILE"
    echo "### Database Query Analysis" >> "$REPORT_FILE"
    
    # Count Eloquent relationships without eager loading
    local lazy_count=$(grep -r "->load(" app/ --include="*.php" 2>/dev/null | wc -l || echo "0")
    echo "- Lazy loading calls found: $lazy_count" >> "$REPORT_FILE"
    
    # Check for compiled assets
    echo "" >> "$REPORT_FILE"
    echo "### Asset Compilation" >> "$REPORT_FILE"
    
    if [[ -d public/build ]]; then
        log_message "success" "Assets are compiled"
        echo "- ✅ Assets are compiled" >> "$REPORT_FILE"
    else
        log_message "warning" "Assets not compiled"
        echo "- ⚠️ Assets not compiled (run: npm run build)" >> "$REPORT_FILE"
    fi
    
    echo "" >> "$REPORT_FILE"
}

# 5. Database Analysis
analyze_database() {
    log_message "header" "DATABASE ANALYSIS"
    
    echo "## 5. Database Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Count migrations
    local migration_count=$(find database/migrations -name "*.php" 2>/dev/null | wc -l)
    echo "### Migration Statistics" >> "$REPORT_FILE"
    echo "- Total migrations: $migration_count" >> "$REPORT_FILE"
    log_message "info" "Total migrations: $migration_count"
    
    # Check for indexes in migrations
    local index_count=$(grep -r "->index()" database/migrations --include="*.php" 2>/dev/null | wc -l || echo "0")
    echo "- Indexes defined: $index_count" >> "$REPORT_FILE"
    
    # Check for foreign keys
    local foreign_count=$(grep -r "->foreign(" database/migrations --include="*.php" 2>/dev/null | wc -l || echo "0")
    echo "- Foreign keys defined: $foreign_count" >> "$REPORT_FILE"
    
    # List models
    echo "" >> "$REPORT_FILE"
    echo "### Models" >> "$REPORT_FILE"
    find app/Models -name "*.php" -exec basename {} .php \; 2>/dev/null | while read model; do
        echo "- $model" >> "$REPORT_FILE"
    done
    
    echo "" >> "$REPORT_FILE"
}

# 6. Dependencies Analysis
analyze_dependencies() {
    log_message "header" "DEPENDENCIES ANALYSIS"
    
    echo "## 6. Dependencies Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Composer packages
    echo "### Composer Dependencies" >> "$REPORT_FILE"
    local composer_count=$(composer show --direct | wc -l)
    echo "- Total direct dependencies: $composer_count" >> "$REPORT_FILE"
    log_message "info" "Composer dependencies: $composer_count"
    
    # Check for outdated packages
    echo "" >> "$REPORT_FILE"
    echo "### Outdated Packages" >> "$REPORT_FILE"
    composer outdated --direct 2>&1 | head -20 >> "$REPORT_FILE" || echo "Unable to check outdated packages" >> "$REPORT_FILE"
    
    # NPM packages
    echo "" >> "$REPORT_FILE"
    echo "### NPM Dependencies" >> "$REPORT_FILE"
    if [[ -f package.json ]]; then
        local npm_count=$(grep -c "\":" package.json | grep -v "{" | grep -v "}" || echo "0")
        echo "- Total NPM dependencies: ~$npm_count" >> "$REPORT_FILE"
        log_message "info" "NPM dependencies: ~$npm_count"
    fi
    
    # Security audit
    echo "" >> "$REPORT_FILE"
    echo "### Security Vulnerabilities" >> "$REPORT_FILE"
    
    # Composer audit
    if command -v composer &> /dev/null; then
        local vuln_count=$(composer audit 2>&1 | grep -c "advisories" || echo "0")
        if [[ $vuln_count -eq 0 ]]; then
            log_message "success" "No known vulnerabilities in Composer packages"
            echo "- ✅ No known vulnerabilities in Composer packages" >> "$REPORT_FILE"
        else
            log_message "warning" "Found vulnerabilities in Composer packages"
            echo "- ⚠️ Found vulnerabilities in Composer packages" >> "$REPORT_FILE"
        fi
    fi
    
    echo "" >> "$REPORT_FILE"
}

# 7. Testing Analysis
analyze_testing() {
    log_message "header" "TESTING ANALYSIS"
    
    echo "## 7. Testing Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Count test files
    local unit_tests=$(find tests/Unit -name "*Test.php" 2>/dev/null | wc -l || echo "0")
    local feature_tests=$(find tests/Feature -name "*Test.php" 2>/dev/null | wc -l || echo "0")
    
    echo "### Test Statistics" >> "$REPORT_FILE"
    echo "- Unit tests: $unit_tests" >> "$REPORT_FILE"
    echo "- Feature tests: $feature_tests" >> "$REPORT_FILE"
    echo "- Total tests: $((unit_tests + feature_tests))" >> "$REPORT_FILE"
    
    log_message "info" "Unit tests: $unit_tests"
    log_message "info" "Feature tests: $feature_tests"
    
    if [[ $((unit_tests + feature_tests)) -eq 0 ]]; then
        log_message "warning" "No tests found"
        echo "" >> "$REPORT_FILE"
        echo "⚠️ **No tests found!** Consider adding tests for better code quality." >> "$REPORT_FILE"
    fi
    
    # Check for PHPUnit configuration
    if [[ -f phpunit.xml ]] || [[ -f phpunit.xml.dist ]]; then
        log_message "success" "PHPUnit configuration found"
        echo "" >> "$REPORT_FILE"
        echo "- ✅ PHPUnit configuration found" >> "$REPORT_FILE"
    else
        log_message "warning" "PHPUnit configuration not found"
        echo "- ⚠️ PHPUnit configuration not found" >> "$REPORT_FILE"
    fi
    
    echo "" >> "$REPORT_FILE"
}

# 8. Documentation Analysis
analyze_documentation() {
    log_message "header" "DOCUMENTATION ANALYSIS"
    
    echo "## 8. Documentation Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Check for README
    if [[ -f README.md ]]; then
        local readme_lines=$(wc -l < README.md)
        log_message "success" "README.md found ($readme_lines lines)"
        echo "- ✅ README.md found ($readme_lines lines)" >> "$REPORT_FILE"
    else
        log_message "warning" "README.md not found"
        echo "- ⚠️ README.md not found" >> "$REPORT_FILE"
    fi
    
    # Check for API documentation
    if [[ -d "storage/api-docs" ]] || [[ -d "public/docs" ]]; then
        log_message "success" "API documentation found"
        echo "- ✅ API documentation found" >> "$REPORT_FILE"
    else
        log_message "info" "No API documentation found"
        echo "- ℹ️ No API documentation found" >> "$REPORT_FILE"
    fi
    
    # Count PHPDoc comments
    local phpdoc_count=$(grep -r "@param\|@return\|@throws" app/ --include="*.php" 2>/dev/null | wc -l || echo "0")
    echo "- PHPDoc comments found: $phpdoc_count" >> "$REPORT_FILE"
    
    echo "" >> "$REPORT_FILE"
}

# 9. Laravel Best Practices
analyze_laravel_practices() {
    log_message "header" "LARAVEL BEST PRACTICES"
    
    echo "## 9. Laravel Best Practices" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Check for service providers
    local providers_count=$(find app/Providers -name "*.php" 2>/dev/null | wc -l)
    echo "### Architecture" >> "$REPORT_FILE"
    echo "- Service Providers: $providers_count" >> "$REPORT_FILE"
    
    # Check for repositories pattern
    if [[ -d "app/Repositories" ]]; then
        log_message "success" "Repository pattern detected"
        echo "- ✅ Repository pattern detected" >> "$REPORT_FILE"
    fi
    
    # Check for service classes
    if [[ -d "app/Services" ]]; then
        log_message "success" "Service layer detected"
        echo "- ✅ Service layer detected" >> "$REPORT_FILE"
    fi
    
    # Check for form requests
    local requests_count=$(find app/Http/Requests -name "*.php" 2>/dev/null | wc -l || echo "0")
    if [[ $requests_count -gt 0 ]]; then
        log_message "success" "Form requests used ($requests_count)"
        echo "- ✅ Form requests used ($requests_count)" >> "$REPORT_FILE"
    else
        log_message "info" "No form requests found"
        echo "- ℹ️ No form requests found" >> "$REPORT_FILE"
    fi
    
    # Check for middleware
    local middleware_count=$(find app/Http/Middleware -name "*.php" 2>/dev/null | wc -l)
    echo "- Custom Middleware: $middleware_count" >> "$REPORT_FILE"
    
    # Check for events and listeners
    if [[ -d "app/Events" ]] && [[ -d "app/Listeners" ]]; then
        local events_count=$(find app/Events -name "*.php" 2>/dev/null | wc -l || echo "0")
        local listeners_count=$(find app/Listeners -name "*.php" 2>/dev/null | wc -l || echo "0")
        echo "- Events: $events_count, Listeners: $listeners_count" >> "$REPORT_FILE"
    fi
    
    echo "" >> "$REPORT_FILE"
}

# 10. Generate Recommendations
generate_recommendations() {
    log_message "header" "GENERATING RECOMMENDATIONS"
    
    echo "## 10. Recommendations" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    echo "### High Priority" >> "$REPORT_FILE"
    
    # Security recommendations
    if grep -q "APP_DEBUG=true" .env 2>/dev/null; then
        echo "1. **Security**: Set APP_DEBUG=false in production" >> "$REPORT_FILE"
    fi
    
    # Performance recommendations
    if [[ ! -f bootstrap/cache/config.php ]]; then
        echo "2. **Performance**: Cache configuration with \`php artisan config:cache\`" >> "$REPORT_FILE"
    fi
    
    if [[ ! -f bootstrap/cache/routes-v7.php ]]; then
        echo "3. **Performance**: Cache routes with \`php artisan route:cache\`" >> "$REPORT_FILE"
    fi
    
    # Testing recommendations
    local total_tests=$((unit_tests + feature_tests))
    if [[ $total_tests -eq 0 ]]; then
        echo "4. **Quality**: Add unit and feature tests" >> "$REPORT_FILE"
    fi
    
    echo "" >> "$REPORT_FILE"
    echo "### Medium Priority" >> "$REPORT_FILE"
    
    # Code quality recommendations
    if [[ $dd_count -gt 0 ]] || [[ $vardump_count -gt 0 ]]; then
        echo "1. **Code Quality**: Remove debug statements (dd, var_dump)" >> "$REPORT_FILE"
    fi
    
    if [[ $console_count -gt 0 ]]; then
        echo "2. **Code Quality**: Remove console.log statements" >> "$REPORT_FILE"
    fi
    
    # Documentation recommendations
    if [[ ! -f README.md ]]; then
        echo "3. **Documentation**: Create a comprehensive README.md" >> "$REPORT_FILE"
    fi
    
    echo "" >> "$REPORT_FILE"
    echo "### Low Priority" >> "$REPORT_FILE"
    echo "1. Consider implementing API versioning" >> "$REPORT_FILE"
    echo "2. Add more PHPDoc comments for better IDE support" >> "$REPORT_FILE"
    echo "3. Implement comprehensive logging strategy" >> "$REPORT_FILE"
    
    echo "" >> "$REPORT_FILE"
}

# Generate JSON report
generate_json_report() {
    cat > "$JSON_REPORT" << JSON
{
    "project": {
        "path": "$PROJECT_ROOT",
        "timestamp": "$TIMESTAMP",
        "laravel_version": "$(php artisan --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo 'unknown')",
        "php_version": "$(php -v | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo 'unknown')"
    },
    "statistics": {
        "total_checks": $TOTAL_CHECKS,
        "passed": $PASSED_CHECKS,
        "failed": $FAILED_CHECKS,
        "warnings": $WARNINGS
    },
    "score": $(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
}
JSON
}

# Main execution
main() {
    echo -e "${COLOR_BOLD}${COLOR_CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   Salbion Group Project Review Tool    ║"
    echo "║           Version 1.0                  ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    
    # Run all analyses
    analyze_project_structure
    analyze_code_quality
    analyze_security
    analyze_performance
    analyze_database
    analyze_dependencies
    analyze_testing
    analyze_documentation
    analyze_laravel_practices
    generate_recommendations
    
    # Generate final summary
    echo "## Summary" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "- **Total Checks:** $TOTAL_CHECKS" >> "$REPORT_FILE"
    echo "- **Passed:** $PASSED_CHECKS ✅" >> "$REPORT_FILE"
    echo "- **Failed:** $FAILED_CHECKS ❌" >> "$REPORT_FILE"
    echo "- **Warnings:** $WARNINGS ⚠️" >> "$REPORT_FILE"
    echo "- **Score:** $(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))%" >> "$REPORT_FILE"
    
    # Generate JSON report
    generate_json_report
    
    # Display summary
    echo -e "\n${COLOR_BOLD}📊 REVIEW SUMMARY${COLOR_RESET}"
    echo -e "════════════════════════════════"
    echo -e "Total Checks: ${COLOR_BOLD}$TOTAL_CHECKS${COLOR_RESET}"
    echo -e "Passed: ${COLOR_GREEN}$PASSED_CHECKS ✅${COLOR_RESET}"
    echo -e "Failed: ${COLOR_RED}$FAILED_CHECKS ❌${COLOR_RESET}"
    echo -e "Warnings: ${COLOR_YELLOW}$WARNINGS ⚠️${COLOR_RESET}"
    echo -e "Score: ${COLOR_BOLD}$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))%${COLOR_RESET}"
    echo -e "\n📄 Full report: $REPORT_FILE"
    echo -e "📊 JSON report: $JSON_REPORT"
    
    # Open report in default editor if available
    if command -v code &> /dev/null; then
        echo -e "\n${COLOR_CYAN}Opening report in VS Code...${COLOR_RESET}"
        code "$REPORT_FILE"
    elif command -v open &> /dev/null; then
        open "$REPORT_FILE"
    fi
}

# Install required tools
install_tools() {
    log_message "info" "Checking required tools..."
    
    # Install tree if not available
    if ! command -v tree &> /dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install tree 2>/dev/null || true
        elif [[ -f /etc/debian_version ]]; then
            sudo apt-get install -y tree 2>/dev/null || true
        fi
    fi
}

# Run installation and main
install_tools
main
