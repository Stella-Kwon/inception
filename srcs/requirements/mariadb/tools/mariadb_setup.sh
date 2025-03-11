#!/bin/sh
# Alpine uses BusyBox sh, so avoid bash-specific features
# Enable debugging
set -x

# echo "Checking environment variables..."
# echo "MYSQL_DATABASE: ${MYSQL_DATABASE}"
# echo "MYSQL_USER: ${MYSQL_USER}"
# echo "MYSQL_PASSWORD: ${MYSQL_PASSWORD}"
# echo "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}"

# 데이터베이스 디렉토리가 비어있는지 확인
    #  [-d PATH ] returns true if PATH exists and is a directory
    #  [ ! -d PATH ] returns true if PATH does not exist or is not a directory

# This checks for a specific required system table file,
# which would only exist in a properly initialized MariaDB installation.
# if [ ! -d "/var/lib/mysql/mysql/user.frm" ]; then
# but user.frm 대신 mysql 디렉토리 자체를 확인해야 합니다.
# user.frm은 일부 MariaDB 버전에서는 존재하지 않을 수도 있습니다.
# MariaDB가 정상적으로 초기화되면 /var/lib/mysql/mysql 디렉터리가 생성되므로, 이걸 기준으로 검사해야 합니다.

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "No existing database found, initializing MariaDB..."
    
# # Ensure runtime directory exists //  have done this at Dockerfile
    # mkdir -p /run/mysqld
    # chown -R mysql:mysql /run/mysqld

    # Creates database files :  Initialize database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    echo "MariaDB data directory initialized."
    

#Starts temporary mysqld in background (PID 2+)
    # 임시 서버 시작 :  running on background (&) as the shell script
    # because now (mariadb_setup.sh) is already running as PID 1.
    # so that Fork a new process for mysqld, 
    # Continue executing the script(mariadb) without waiting for mysqld to finish
    # & specifically creates a background process, which by definition is not the main process

#  Disable network connections, only allowing local connections through Unix socket
    # Start temporary MariaDB server WITHOUT NETWORKING
    # This is important for security during initialization :  will restart again so it will connect to network
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$! #  Store the process ID of the background command in the MYSQL_PID variable
    
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
    max_wait=60
    
    # Wait for startup (with proper error handling for Alpine)
    until mysqladmin ping >/dev/null 2>&1
    do
        sleep 2
        count=$((count+2))
        if [ $count -gt $max_wait ]; then
            echo "Error: MariaDB took too long to start"
            kill $MYSQL_PID
            exit 1
        fi
    done
    echo "MariaDB is up and running!"
    
    # Check environment variables
    if [ -z "${MYSQL_DATABASE}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
        echo "Error: Required environment variables are not set"
        kill $MYSQL_PID
        exit 1
    fi

    # Setup the database and user first
    echo "Setting up database and users..."
    mysql -u root <<EOF
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    # Verify user creation
    echo "Verifying user creation..."
    mysql -u root -e "SELECT User, Host FROM mysql.user WHERE User='${MYSQL_USER}';"
    
    # Set root password
    echo "Setting root password..."
    # Use SQL command instead of mysqladmin for greater compatibility
    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    
    # Shutdown MariaDB gracefully
    echo "Stopping temporary MariaDB server..."
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown || kill $MYSQL_PID
fi

# Start MariaDB as the main process
echo "Starting MariaDB as the main process..."
exec mysqld --user=mysql