-- 이 파일은 실제로 사용되지 않고 mariadb_setup.sh에서 환경 변수를 사용하여 동적으로 생성됩니다.
-- SQL files typically can't process shell environment variables directly
-- 참조용으로만 유지합니다.
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; 