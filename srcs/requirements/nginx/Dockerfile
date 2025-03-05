# Nginx 이미지 빌드
# getting image from dockerhub
FROM alpine:3.16 


# Load build arguments (from docker-compose) from .env
ARG DOMAIN_NAME
ARG SSL_DIR

# 필요한 패키지 설치

# --no-cache 옵션은 불필요한 캐시 파일을 남기지 않도록 합니다.
RUN apk update && apk add --no-cache nginx openssl

# SSL 설정
RUN mkdir -p ${SSL_CERTS}
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ${SSL_CERTS}/nginx.key \
    -out ${SSL_CERTS}/nginx.crt \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42Helsinki/OU=42Helsinki/CN=${DOMAIN_NAME}"

# NGINX 설정 파일 복사
# The COPY command in Dockerfile only copies files from your local machine (or project directory) into the container. 
COPY conf/nginx.conf /etc/nginx/nginx.conf

# 디렉토리 생성
RUN mkdir -p /var/www/html

#NGINX requires a directory to store its PID (Process ID) file and other runtime data.
RUN mkdir -p /run/nginx 

# EXPOSE 자체는 컨테이너의 네트워크 설정을 변경하지 않으며, docker run -p 443:443 옵션을 함께 사용해야 합니다.
# i already mentioned it on my compose file.
EXPOSE 443 


# NGINX 실행 // run as pid 1 
CMD ["nginx", "-g", "daemon off;"]
