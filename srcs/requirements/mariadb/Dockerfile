FROM alpine:3.16

# 필요한 패키지 설치
RUN apk update && apk add --no-cache mariadb mariadb-client

# MariaDB 설정 파일 복사
COPY conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf

# 초기화 스크립트 복사
COPY tools/mariadb_setup.sh /usr/local/bin/
COPY tools/init.sql /docker-entrypoint-initdb.d/

# 실행 권한 부여
RUN chmod +x /usr/local/bin/mariadb_setup.sh

# 데이터 디렉토리 설정
RUN mkdir -p /run/mysqld /var/lib/mysql
RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql

EXPOSE 3306

# MariaDB 초기화 및 실행
ENTRYPOINT ["/usr/local/bin/mariadb_setup.sh"] 