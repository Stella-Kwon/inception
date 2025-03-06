FROM alpine:3.16

# 필요한 패키지 설치
#mariadb-client package contains command-line utilities for connecting to and interacting with MariaDB (or MySQL) servers
RUN apk update && apk add --no-cache mariadb mariadb-client

# MariaDB 설정 파일 복사
COPY conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf

# 초기화 스크립트 복사
# /usr/local/bin/:  a standard location for executable scripts in Linux
    #  Your main entry point script
    # this directory is in the system PATH and is where you place executables/scripts that should be directly runnable from anywhere in the system

# /docker-entrypoint-initdb.d/ (a convention in database container images)
    # is a special convention used by official database images,
        #where initialization scripts are automatically discovered and executed
    # but right now, init.sql has environment variables inside so i customed my setup.sh file have the script inside.
    # but with (The gettext package provides the envsubst command) this will allow you to use env variable to be read in sql file 
COPY tools/mariadb_setup.sh /usr/local/bin/
COPY tools/init.sql /docker-entrypoint-initdb.d/ 

# 실행 권한 부여
RUN chmod +x /usr/local/bin/mariadb_setup.sh

# 데이터 디렉토리 설정
# /run/mysqld needed for mariadb's runtime files
# The /run directory in modern Linux systems is typically:
    # Mounted as a tmpfs filesystem (in-memory  = RAM)
    # Cleared on system reboot
    # Used for runtime files that don't need to persist
# it serves to
    # store its process ID in a file like mysqld.pid : allows other processes to know which PID belongs to the database server for proper process management
    # Socket File Location:
    #     MariaDB creates a Unix socket file (typically mysql.sock) in this directory
    #     Local connections often use this socket file instead of TCP/IP networking for better performance

##########################################################################################################################


# When to Use TCP/IP vs Sockets
    # Use Unix Sockets when:

        # The client and server are on the same physical machine
        # Maximum performance is needed for local connections
        # You want to avoid network-related security concerns

    # Use TCP/IP when:

        # The client and server are on different machines
        # Containers need to communicate across hosts
        # Your application is distributed across multiple servers
        # You need to connect from remote clients
        # Cross-platform communication is required (e.g., Windows clients)


# BUTTTTT
# In Container Environments
    # In Docker:

    # Containers on the same host but in different containers typically use TCP/IP through Docker's network bridges
    # Containers that share volumes can potentially use Unix sockets through a shared volume
    # Most container setups default to TCP/IP because it's more flexible across container boundaries

    # This is why in your MariaDB container, even though the socket file is set up, your other containers will likely connect via TCP/IP on port 3306.
##########################################################################################################################

RUN mkdir -p /run/mysqld /var/lib/mysql

#The mysql user has proper permissions to write socket and PID files
# MariaDB can start without permission errors
RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql

#port 3306 is the standard default port for MySQL/MariaDB
EXPOSE 3306

# MariaDB 초기화 및 실행 -> EntryPoint will set it as PID 1
# The shell script is responsible for process management inside the container
ENTRYPOINT ["/usr/local/bin/mariadb_setup.sh"]