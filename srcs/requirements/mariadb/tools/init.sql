-- 이 파일은 실제로 사용되지 않고 mariadb_setup.sh에서 환경 변수를 사용하여 동적으로 생성됩니다.
-- SQL files typically can't process shell environment variables directly
-- 참조용으로만 유지합니다.

-- SQL initialization script that will be dynamically created using environment variables
-- This script sets up the initial database, user, and permissions

-- Create the main application database if it doesn't exist
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Create a user account that can connect from any host (%)
-- The % wildcard allows connections from any IP address
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

-- Grant full permissions to this user on the created database
-- This allows the user to create, read, update, and delete data in the database
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Apply the privilege changes immediately
FLUSH PRIVILEGES;

-- Set a secure password for the root user
-- This changes the default root password for security purposes
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';