#!/bin/sh

# 데이터베이스 디렉토리가 비어있는지 확인
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # 데이터베이스 초기화
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # 임시 서버 시작
    mysqld --user=mysql --datadir=/var/lib/mysql &
    
    # 서버가 시작될 때까지 대기
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    # 환경 변수로 SQL 파일 생성
    cat > /tmp/init.sql << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
EOF

    # SQL 실행
    mysql < /tmp/init.sql
    
    # 임시 서버 종료
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
    
    # 임시 SQL 파일 삭제
    rm /tmp/init.sql
fi

# MariaDB 서버 실행
exec mysqld --user=mysql 