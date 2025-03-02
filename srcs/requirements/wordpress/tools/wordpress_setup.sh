#!/bin/sh

# WordPress CLI 설치
if [ ! -f "/usr/local/bin/wp" ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# WordPress 디렉토리로 이동
cd /var/www/html/wordpress

# WordPress가 이미 설치되어 있는지 확인
if ! wp core is-installed --allow-root; then
    # WordPress 코어 설치
    wp core install --allow-root \
        --url=${DOMAIN_NAME} \
        --title="WordPress Site" \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --skip-email

    # 추가 사용자 생성
    wp user create --allow-root \
        ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} \
        --role=author \
        --user_pass=${WORDPRESS_USER_PASSWORD}
fi

# 권한 설정
chown -R nobody:nobody /var/www/html/wordpress

# PHP-FPM 실행
exec php-fpm8 -F 