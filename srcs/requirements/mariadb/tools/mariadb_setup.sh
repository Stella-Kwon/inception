#!/bin/sh
# If any command fails, the script stops immediately instead of continuing with potential errors.
set -e

# 데이터베이스 디렉토리가 비어있는지 확인
#  [-d PATH ] returns true if PATH exists and is a directory
#  [ ! -d PATH ] returns true if PATH does not exist or is not a directory
# This checks for a specific required system table file, which would only exist in a properly initialized MariaDB installation.
# if [ ! -d "/var/lib/mysql/mysql/user.frm" ]; then
# but user.frm 대신 mysql 디렉토리 자체를 확인해야 합니다.
# user.frm은 일부 MariaDB 버전에서는 존재하지 않을 수도 있습니다.
# MariaDB가 정상적으로 초기화되면 /var/lib/mysql/mysql 디렉터리가 생성되므로, 이걸 기준으로 검사해야 합니다.
   
if [ ! -d "/var/lib/mysql/mysql" ]; then
     echo "No existing database found, initializing MariaDB..."

    # # Ensure runtime directory exists //  have done this at Dockerfile
    # mkdir -p /run/mysqld
    # chown -R mysql:mysql /run/mysqld


    # 데이터베이스 초기화
    # Creates database files
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    echo "MariaDB data directory initialized."
    #Starts temporary mysqld in background (PID 2+)
    # 임시 서버 시작 :  running on background as the shell script (mariadb_setup.sh) is already running as PID 1.
    # so that Fork a new process for mysqld, 
    # Continue executing the script(mariadb) without waiting for mysqld to finish
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
    
    # #-gt : greater than
    # Wait for MariaDB to be ready before executing sql commands to prevent race condition
    echo "Waiting for MariaDB to start..."
    count=0
    max_wait=60  # Increase timeout to 60 seconds

    #because of set -e
    # you need || true; 
    # to allow mysqladmin to fail without stopping the script
    until mysqladmin ping --silent || true; do
        sleep 2
        count=$((count+2))
        if [ $count -gt $max_wait ]; then
            echo "Error: MariaDB took too long to start"
            exit 1
        fi
    done
    echo "MariaDB is up and running!"

    # Check if environment variables are set :  -z checks empty or not
    if [ -z "${MYSQL_DATABASE}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
        echo "Error: Required environment variables are not set : empty"
        exit 1
    fi


 # can use this alternative way then below.
    # # 환경 변수를 init.sql 파일에 적용
    # # Use envsubst to replace environment variables in the SQL file
    # envsubst < /docker-entrypoint-initdb.d/init.sql > /tmp/init.sql

    # Configures database
    # 환경 변수로 SQL 파일 생성
    # Everything between the two EOF markers is written to the file /tmp/init.sql


    cat > /tmp/init.sql << EOF
DROP DATABASE IF EXISTS test; 
DELETE FROM mysql.db WHERE Db='test';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
EOF

    echo "Running initial SQL script..."
    if ! mysql < /tmp/init.sql; then
        echo "Error: Failed to execute SQL initialization script"
        cat /tmp/init.sql  # Print the script for debugging
        exit 1
    fi
    echo "Initial SQL script executed successfully!"

    # Shut down temporary MariaDB process
    echo "Stopping temporary MariaDB server..."
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

    # Remove temporary SQL script
    rm /tmp/init.sql
fi

# Start MariaDB as the main process
echo "Starting MariaDB as the main process..."
exec mysqld --user=mysql