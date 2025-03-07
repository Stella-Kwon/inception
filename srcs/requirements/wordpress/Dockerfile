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

# Create nginx user (in case it doesn’t exist)
# -D (short for --disabled-password) creates a system user without a password.
# -g 'nginx' assigns the user to the group named nginx.
#importanat~~ you need to create here first to connect to nginx
RUN adduser -D -g 'nginx' nginx


# WordPress 설치
    #chown → Changes the owner of a file or directory.
    # -R (Recursive) → Applies the ownership to all files and subdirectories inside /var/www/html/.
    # nobody:nobody → Assigns the user nobody and group nobody as the owners.
WORKDIR /var/www/html
RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    rm latest.zip && \
# 기존 nobody 소유권을 nginx로 변경: Nginx 웹 서버가 파일에 접근할 수 있도록 소유권을 변경해야 합니다.
    chown -R nginx:nginx /var/www/html/

# PHP-FPM 설정 파일 복사
COPY conf/www.conf /etc/php8/php-fpm.d/www.conf

# WordPress 설정 파일 복사
COPY tools/wp-config.php /var/www/html/wordpress/

# WordPress 설치 스크립트 복사 및 실행 권한 부여
COPY tools/wordpress_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress_setup.sh

# 필요한 디렉토리 생성
RUN mkdir -p /run/php

#for documentation 
EXPOSE 9000

#to ensure always setup runs to make wp runs propely.
ENTRYPOINT ["/usr/local/bin/wordpress_setup.sh"]
