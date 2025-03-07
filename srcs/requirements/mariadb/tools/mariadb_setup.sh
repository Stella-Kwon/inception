#!/bin/sh

# 데이터베이스 디렉토리가 비어있는지 확인

#  [-d PATH ] returns true if PATH exists and is a directory
#  [ ! -d PATH ] returns true if PATH does not exist or is not a directory

if [ ! -d "/var/lib/mysql/mysql" ]; then
    # 데이터베이스 초기화
    # Creates database files
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    #Starts temporary mysqld in background (PID 2+)
    # 임시 서버 시작 :  running on background as the shell script (mariadb_setup.sh) is already running as PID 1.
    # so that Fork a new process for mysqld, Continue executing the script without waiting for mysqld to finish
    # & specifically creates a background process, which by definition is not the main process
   
    mysqld --user=mysql --datadir=/var/lib/mysql &
    
    # 서버가 시작될 때까지 대기
    # >/dev/null redirects standard output (stdout) to /dev/null (discards it)
    # 2>&1 redirects standard error (stderr) to the same place as standard output (also discards it)
    
# until mysqladmin ping >/dev/null 2>&1; do sleep 1 done means:

# Run mysqladmin ping (which checks if the MySQL/MariaDB server is accessible)
# Discard all output (both stdout and stderr)
# If the command fails (server not ready), sleep for 1 second
# Repeat until the command succeeds (which means the server is up)
    
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done


    # can use this alternative way then below.
    # # 환경 변수를 init.sql 파일에 적용
    # # Use envsubst to replace environment variables in the SQL file
    # envsubst < /docker-entrypoint-initdb.d/init.sql > /tmp/init.sql

# Configures database
# 환경 변수로 SQL 파일 생성
# Everything between the two EOF markers is written to the file /tmp/init.sql

# Check if environment variables are set
if [ -z "${MYSQL_DATABASE}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
    echo "Error: Required environment variables are not set"
    exit 1
fi

cat > /tmp/init.sql << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
EOF

if ! mysql < /tmp/init.sql; then
    echo "Error: Failed to execute SQL initialization script"
    cat /tmp/init.sql  # Print the script to see what went wrong
    exit 1
fi


    # SQL 실행
    mysql < /tmp/init.sql
    
    # 임시 서버 종료
    # Shuts down temporary mysqld and
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
    
    # 임시 SQL 파일 삭제
    rm /tmp/init.sql
fi

#Start the mysqld again with pid1
# MariaDB 서버 실행
# exec mysqld (without &) does mysqld replace the shell and become PID 1
exec mysqld --user=mysql 