# Nginx 이미지 빌드
# getting image from dockerhub 
# but there is ready version as well : FROM nginx:1.24-alpine : if you need
FROM alpine:3.16 


# Load build arguments (from docker-compose) from .env 
# but if you have enviornment in compose file you dont need

#Build-time arguments (only used during docker build)
ARG DOMAIN_NAME
ARG SSL_CERTS

#Runtime environment variables (persist inside the running container)
ENV DOMAIN_NAME=${DOMAIN_NAME}
ENV SSL_CERTS=${SSL_CERTS}

# 필요한 패키지 설치

# --no-cache 옵션은 불필요한 캐시 파일을 남기지 않도록 합니다.
RUN apk update && apk add --no-cache nginx openssl


#for user www-data
# # Create www-data user and group (matching common Linux IDs)
# RUN addgroup -g 82 -S www-data && adduser -u 82 -D -S -G www-data www-data

# SSL 설정
RUN mkdir -p ${SSL_CERTS}
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${SSL_CERTS}/${DOMAIN_NAME}.key" \
    -out "${SSL_CERTS}/${DOMAIN_NAME}.crt" \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Hive/CN=${DOMAIN_NAME}"

# NGINX 설정 파일 복사
# The COPY command in Dockerfile only copies files from your local machine (or project directory) into the container. 
COPY conf/nginx.conf /etc/nginx/nginx.conf

# 디렉토리 생성
RUN mkdir -p /var/www/html

#NGINX requires a directory to store its PID (Process ID) file and other runtime data.
RUN mkdir -p /run/nginx 

#for user www-data
# # Set proper permissions for www-data
# RUN chown -R www-data:www-data /var/www/html /run/nginx

# EXPOSE 자체는 컨테이너의 네트워크 설정을 변경하지 않으며, docker run -p 443:443 옵션을 함께 사용해야 합니다.
# i already mentioned it on my compose file.
EXPOSE 443 

#By default, NGINX runs in the background (daemon mode).
# -g "daemon off;" forces it to run in the foreground, keeping the container running

# make sure conf file is not in /etc/nginx/nginx.conf
# CMD ["nginx", "-c", "/custom/path/nginx.conf", "-g", "daemon off;"]

# NGINX 실행 // run as pid 1 
CMD ["nginx", "-g", "daemon off;"]
