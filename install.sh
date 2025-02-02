#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${YELLOW}[*] $1${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}[+] $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}[-] $1${NC}"
    exit 1
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root"
fi

print_status "Starting Laravel Project Installation..."

# Install required system packages
print_status "Installing system dependencies..."
apt-get update
apt-get install -y \
    php8.2 \
    php8.2-cli \
    php8.2-fpm \
    php8.2-common \
    php8.2-mysql \
    php8.2-zip \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-curl \
    php8.2-xml \
    php8.2-bcmath \
    php8.2-sqlite3 \
    nginx \
    curl \
    unzip \
    git

# Install Node.js 20.x
print_status "Installing Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install Composer
if ! command -v composer &> /dev/null; then
    print_status "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi

# Clone the repository
print_status "Cloning the Laravel project..."
git clone https://github.com/scarar/my-laravel-project.git laravelProject
cd laravelProject

# Set up environment file
print_status "Setting up environment file..."
cp .env.example .env

# Install PHP dependencies
print_status "Installing PHP dependencies..."
composer install --no-dev --optimize-autoloader

# Generate application key
print_status "Generating application key..."
php artisan key:generate

# Install Node.js dependencies
print_status "Installing Node.js dependencies..."
npm install

# Build frontend assets
print_status "Building frontend assets..."
npm run build

# Run database migrations
print_status "Running database migrations..."
php artisan migrate --force

# Create storage link
print_status "Creating storage link..."
php artisan storage:link

# Optimize Laravel
print_status "Optimizing Laravel..."
php artisan optimize
php artisan view:cache
php artisan config:cache
php artisan route:cache

# Set correct permissions
print_status "Setting correct permissions..."
chown -R www-data:www-data .
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
chmod -R 775 storage bootstrap/cache

print_success "Installation completed successfully!"
echo -e "${GREEN}Your Laravel project is now installed and configured!${NC}"
NC='\033[0m' # No Color

# Welcome message
echo -e "${GREEN}Welcome to the Laravel production preparation script!${NC}"

# Ensure the script is run from the correct directory
if [ ! -f "composer.json" ]; then
  echo -e "${RED}Error: composer.json not found. Please run this script from the Laravel project root directory.${NC}"
  exit 1
fi

# Install Composer dependencies with optimization
echo "Installing Composer dependencies..."
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-interaction --optimize-autoloader --no-dev
echo -e "${GREEN}Composer dependencies installed successfully.${NC}"

# Generate application key
echo "Generating application key..."
php artisan key:generate
echo -e "${GREEN}Application key generated successfully.${NC}"

# Cache configuration, routes, and views
echo "Caching configuration, routes, and views..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
echo -e "${GREEN}Configuration, routes, and views cached successfully.${NC}"

# Compile assets using Laravel Mix
echo "Compiling assets..."
npm install && npm run prod
echo -e "${GREEN}Assets compiled successfully.${NC}"

# Set permissions for storage and bootstrap/cache
echo "Setting permissions for storage and cache..."
chmod -R 775 storage bootstrap/cache
echo -e "${GREEN}Permissions set successfully.${NC}"

# Final message
echo -e "${GREEN}Laravel production preparation is complete! Please configure your web server to serve the public directory of this Laravel application.${NC}"