#!/bin/bash

set -e

# Root password를 설정하지 않으면 컨테이너 종료
if [[ -z "${MARIADB_ROOT_PASSWORD:=}" ]]; then 
    echo "ERROR:MARIADB_ROOT_PASSWORD is not set! Exiting."
    exit 1
fi

echo "Initializing with UID($USRID), GID($GRPID)"
echo "Current user: $(id -u)"
echo "MariaDB user: $(id -u $MARIADB_USER)"
echo "MariaDB group: $(id -g $MARIADB_USER)"

# 컨테이너가 루트 권한으로 시작된 경우
if [ "$(id -u)" = '0' ]; then
    # MariaDB 사용자와 그룹 ID가 Docker 실행자와 다를 경우 변경
    if [ $(id -u $MARIADB_USER) -ne $USRID ] || [ $(id -g $MARIADB_USER) -ne $GRPID ]; then
        echo "Adjusting MariaDB user/group to match Docker executor (UID: $USRID, GID: $GRPID)"
        deluser $MARIADB_USER
        addgroup -g $GRPID $MARIADB_USER
        adduser -u $USRID -D -G $MARIADB_USER $MARIADB_USER
        chown -R $MARIADB_USER:$MARIADB_USER $MARIADB_CONF_DIR $MARIADB_LOG_DIR $MARIADB_DATA_DIR
    fi
    # MariaDB 사용자로 실행
    exec su-exec $MARIADB_USER $0 $@
fi

# my.cnf 설정 적용
export CONF_FILE=$MARIADB_CONF_DIR/my.cnf

# 필수 설정
sed -i -e "s/%port%/${MARIADB_PORT}/" ${CONF_FILE}

replace_dataDir=$(echo "${MARIADB_DATA_DIR}" | sed 's/\//\\\//g')
sed -i -e "s/%dataDir%/${replace_dataDir}/" ${CONF_FILE}

replace_confDir=$(echo "${MARIADB_CONF_DIR}" | sed 's/\//\\\//g')
sed -i -e "s/%confDir%/${replace_confDir}/" ${CONF_FILE}

replace_logDir=$(echo "${MARIADB_LOG_DIR}" | sed 's/\//\\\//g')
sed -i -e "s/%logDir%/${replace_logDir}/" ${CONF_FILE}

# 연결 설정
max_connections=$(echo "${MARIADB_MAX_CONNECTIONS}" | sed 's/\//\\\//g')
sed -i -e "s/%max_connections%/${max_connections}/" ${CONF_FILE}

connect_timeout=$(echo "${MARIADB_CONNECT_TIMEOUT}" | sed 's/\//\\\//g')
sed -i -e "s/%connect_timeout%/${connect_timeout}/" ${CONF_FILE}

wait_timeout=$(echo "${MARIADB_WAIT_TIMEOUT}" | sed 's/\//\\\//g')
sed -i -e "s/%wait_timeout%/${wait_timeout}/" ${CONF_FILE}

interactive_timeout=$(echo "${MARIADB_INTERACTIVE_TIMEOUT}" | sed 's/\//\\\//g')
sed -i -e "s/%interactive_timeout%/${interactive_timeout}/" ${CONF_FILE}

# 로그 레벨 설정
if [[ -z "${log_level:=}" ]]; then
    sed -i -e "s/%log_level%/2/" ${CONF_FILE}
else
    sed -i -e "s/%log_level%/${log_level}/" ${CONF_FILE}
fi

# 데이터베이스가 없으면 초기화하고 MariaDB 시작
if [[ ! -d "$MARIADB_DATA_DIR/mysql" ]]; then
    # fg 명령을 사용하기 위해 필요
    set -m

    # /var/lib/mysql 초기화
    mysql_install_db --datadir="$MARIADB_DATA_DIR" --skip-test-db

    # 백그라운드에서 MariaDB 실행
    mysqld_safe &
    
    # 서버가 준비될 때까지 대기
    until mysqladmin -u root status 2>/dev/null
    do
        sleep 0.5
    done

    # 루트 비밀번호 변경
    mysqladmin -u root password "$MARIADB_ROOT_PASSWORD"
    echo "Root password set to: $MARIADB_ROOT_PASSWORD"

    sleep 1

    # 권한 설정
    mysql -u root "-p${MARIADB_ROOT_PASSWORD}" -e \
                  " \
                   CREATE USER 'root'@'%' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD'; \
                   GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION; \
                   FLUSH PRIVILEGES; \
                  "

    # 환경 변수로 전달된 사용자 및 데이터베이스 설정
    if [[ -n "${MARIADB_DATABASE:=}" && "${MARIADB_USERNAME:=}" && "${MARIADB_PASSWORD:=}" ]]; then
        mysql -u root "-p${MARIADB_ROOT_PASSWORD}" -e \
                      " \
                       CREATE DATABASE $MARIADB_DATABASE; \
                       CREATE USER '$MARIADB_USERNAME' IDENTIFIED BY '$MARIADB_PASSWORD'; \
                       GRANT USAGE ON *.* TO '$MARIADB_USERNAME'@'%' IDENTIFIED BY '$MARIADB_PASSWORD'; \
                       GRANT ALL privileges ON $MARIADB_DATABASE.* TO '$MARIADB_USERNAME'@'%'; \
                       FLUSH PRIVILEGES; \
                      "
        echo "Created database: $MARIADB_DATABASE"
        echo "Created User: $MARIADB_USERNAME"
        echo "Created Password = $MARIADB_PASSWORD"
    else
        echo "WARNING:MARIADB_DATABASE, MARIADB_USERNAME, and/or MARIADB_PASSWORD not set, skipping database creation."
    fi
    
    # 백그라운드 작업을 포그라운드로 가져오기
    fg %1
else
    echo "$MARIADB_DATA_DIR/mysql exists, skipping initialization."
    mysqld_safe
fi
