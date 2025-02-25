#!/bin/bash

# WordPress CLI 설치
if [ ! -f "/usr/local/bin/wp" ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# WordPress 코어 설치
wp core install --path=/var/www/html/wordpress \
    --url=${DOMAIN_NAME} \
    --title="WordPress Site" \
    --admin_user=${WORDPRESS_ADMIN_USER} \
    --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
    --admin_email=${WORDPRESS_ADMIN_EMAIL} \
    --skip-email

# 추가 사용자 생성
wp user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} \
    --role=author \
    --user_pass=${WORDPRESS_USER_PASSWORD} \
    --path=/var/www/html/wordpress

# 권한 설정
chown -R www-data:www-data /var/www/html/wordpress 