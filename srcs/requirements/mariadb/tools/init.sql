-- 이 파일은 실제로 사용되지 않고 mariadb_setup.sh에서 환경 변수를 사용하여 동적으로 생성됩니다.
-- SQL files typically can't process shell environment variables directly
-- 참조용으로만 유지합니다.

-- SQL initialization script that will be dynamically created using environment variables
-- This script sets up the initial database, user, and permissions

-- while installation of MySQL/MariaDB, test database created primarily, so this can be vulnerable to get attacked as it is accessible to anyone
DROP DATABASE IF EXISTS test; 
DELETE FROM mysql.db WHERE Db='test';

--이것은 검색이나 정렬 시 대소문자 구분 없이 결과를 반환하게 됩니다.
-- WordPress와 같은 애플리케이션에서는 보통 이런 설정을 사용합니다.

-- Create the main application database if it doesn't exist
-- 이것은 검색이나 정렬 시 대소문자 구분 없이 결과를 반환하게 됩니다.
-- WordPress와 같은 애플리케이션에서는 보통 이런 설정을 사용합니다.
-- i set it in my.cnf
-- CREATE DATABASE F NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci ;
CREATE DATABASE F NOT EXISTS ${MYSQL_DATABASE};

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