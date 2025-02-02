#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Welcome message
echo -e "${GREEN}Welcome to the Laravel installation script!${NC}"

# Check if .env file exists
if [ ! -f ".env" ]; then
  cp .env.example .env
  echo -e "${GREEN}Environment file created from example.${NC}"
else
  echo -e "${GREEN}Environment file already exists.${NC}"
fi

# Install Composer dependencies
echo "Installing Composer dependencies..."
composer install --no-interaction
echo -e "${GREEN}Composer dependencies installed successfully.${NC}"

# Generate application key
echo "Generating application key..."
php artisan key:generate
echo -e "${GREEN}Application key generated successfully.${NC}"

# Set permissions for storage
echo "Setting permissions for storage..."
chmod -R 775 storage
chmod -R 775 bootstrap/cache
echo -e "${GREEN}Permissions set successfully.${NC}"

# Final message
echo -e "${GREEN}Laravel installation is complete! You can now start the server using: php artisan serve${NC}"