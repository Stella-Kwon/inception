#!/bin/sh

# Check MariaDB connection
# MariaDB 연결 확인
# -ge equal of greater
attempts=0
while ! mariadb -h$WORDPRESS_DB_HOST -u$WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD $WORDPRESS_DB_NAME &>/dev/null; do
    attempts=$((attempts + 1))
    echo "MariaDB unavailable. Attempt $attempts: Trying again in 5 sec."
    if [ $attempts -ge 12 ]; then
        echo "Max attempts reached. MariaDB connection could not be established."
        exit 1
    fi
    sleep 5
done
echo "MariaDB connection established!"
echo "Listing databases:"
mariadb -h$WORDPRESS_DB_HOST -u$WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD $WORDPRESS_DB_NAME <<EOF
SHOW DATABASES;
EOF

# Check if WordPress directory exists
if [ ! -d "/var/www/html/wordpress" ]; then
    mkdir -p /var/www/html/wordpress
fi

# Check and install WordPress CLI
# curl command is used to download files from the internet
# -O (uppercase)	Saves the file with its original name.
# -o filename (lowercase)	Saves the file with a custom name.
# wget https://wordpress.org/latest.zip :  same thing as curl -O
#!/bin/sh

if [ ! -f "/usr/local/bin/wp" ]; then
    echo "Downloading WordPress CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Change to WordPress directory
cd /var/www/html/wordpress

# Download WordPress core if not present
if [ ! -f "wp-config.php" ] && [ ! -f "wp-config-sample.php" ]; then
    echo "Downloading WordPress core..."
    wp core download --allow-root
fi

# Create WordPress config file if not present
if [ ! -f "wp-config.php" ]; then
    echo "Creating WordPress config file..."
    wp config create --allow-root \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$MYSQL_HOST \
        --path=/var/www/html/wordpress/ \
        --force
fi

# Check if WordPress is already installed
if ! wp core is-installed --allow-root; then
    echo "Installing WordPress..."
    # Install WordPress core
    wp core install --allow-root \
        --url=${DOMAIN_NAME} \
        --title="skwon2's Blog" \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --skip-email
    
    # Create additional user
    wp user create --allow-root \
        ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} \
        --role=author \
        --user_pass=${WORDPRESS_USER_PASSWORD}
    
    # Install and activate theme
    wp theme install neve --activate --allow-root
    
    # Update plugins
    wp plugin update --all --allow-root

    # Update WordPress URL settings
    wp option update siteurl "https://${DOMAIN_NAME}" --allow-root
    wp option update home "https://${DOMAIN_NAME}" --allow-root
fi

# Set permissions 
echo "Setting file permissions..."
# set user ngix: group nginix to get the permission to wp
chown -R nginx:nginx /var/www/html/wordpress
# 755 권한은 웹 서버(nginx)만 파일을 수정할 수 있게 하여 보안을 강화합니다.
chmod -R 755 /var/www/html/wordpress

# Add write permissions to specific directories
wp_content_dir="/var/www/html/wordpress/wp-content"
if [ -d "$wp_content_dir" ]; then
    # Grant write permissions to uploads, plugins, themes directories
    mkdir -p "$wp_content_dir/uploads"
    chmod -R 775 "$wp_content_dir/uploads"
    chmod -R 775 "$wp_content_dir/plugins"
    chmod -R 775 "$wp_content_dir/themes"
fi

# 리눅스 배포판마다 PHP-FPM의 실행 파일 이름이 다를 수 있습니다.
# Check PHP-FPM version and run
if command -v php-fpm8 &> /dev/null; then
    echo "Running PHP-FPM8..."
    exec php-fpm8 -F
elif command -v php-fpm81 &> /dev/null; then
    echo "Running PHP-FPM81..."
    exec php-fpm81 -F
elif command -v php-fpm &> /dev/null; then
    echo "Running PHP-FPM..."
    exec php-fpm -F
else
    echo "PHP-FPM not found. Please check your PHP version."
    exit 1
fi