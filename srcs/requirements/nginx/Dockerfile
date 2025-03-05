# Nginx 이미지 빌드
# getting image from dockerhub
FROM alpine:3.16 

# 필요한 패키지 설치
RUN apk update && apk add --no-cache nginx openssl

# SSL 설정
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=42Seoul/CN=your_login.42.fr"

# NGINX 설정 파일 복사
COPY conf/nginx.conf /etc/nginx/http.d/default.conf

# 디렉토리 생성
RUN mkdir -p /var/www/html
RUN mkdir -p /run/nginx

EXPOSE 443

# NGINX 실행
CMD ["nginx", "-g", "daemon off;"]
