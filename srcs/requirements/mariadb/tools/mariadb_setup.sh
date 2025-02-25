#!/bin/bash

# MySQL 데이터 디렉토리 초기화
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # MySQL 서버 시작
    mysqld_safe --datadir=/var/lib/mysql &
    
    # MySQL 서버가 시작될 때까지 대기
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    # 초기 설정 실행
    mysql -u root < /docker-entrypoint-initdb.d/init.sql
    
    # MySQL 서버 종료
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
fi

# MySQL 서버 실행
exec mysqld --user=mysql --console 