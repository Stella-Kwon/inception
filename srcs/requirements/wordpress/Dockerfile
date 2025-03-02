FROM alpine:3.16

# 필요한 패키지 설치
RUN apk update && apk add --no-cache \
    php8 \
    php8-fpm \
    php8-mysqli \
    php8-json \
    php8-curl \
    php8-dom \
    php8-exif \
    php8-fileinfo \
    php8-mbstring \
    php8-openssl \
    php8-xml \
    php8-zip \
    php8-phar \
    curl \
    wget \
    unzip

# WordPress 설치
WORKDIR /var/www/html
RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    rm latest.zip && \
    chown -R nobody:nobody /var/www/html

# PHP-FPM 설정 파일 복사
COPY conf/www.conf /etc/php8/php-fpm.d/www.conf

# WordPress 설정 파일 복사
COPY tools/wp-config.php /var/www/html/wordpress/

# WordPress 설치 스크립트 복사 및 실행 권한 부여
COPY tools/wordpress_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress_setup.sh

# 필요한 디렉토리 생성
RUN mkdir -p /run/php

EXPOSE 9000

# PHP-FPM 실행
CMD ["php-fpm8", "-F"] 