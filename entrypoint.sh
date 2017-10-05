#!/bin/bash

EBOT_WEB_HOME='/var/www/html'

EBOT_IP="${EBOT_IP:-}"
EBOT_PORT="${EBOT_PORT:-12360}"

MYSQL_HOST="${MYSQL_HOST:-mysql}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-ebotv3}"
MYSQL_PASS="${MYSQL_PASS:-ebotv3}"
MYSQL_DB="${MYSQL_DB:-ebotv3}"

DEMO_DOWNLOAD="${DEMO_DOWNLOAD:-true}"
DEMO_FOLDER="${DEMO_FOLDER:-/opt/ebot/demos}"
LOG_FOLDER="${LOG_FOLDER:-/opt/ebot/logs}"

EBOT_ADMIN_USER="${EBOT_ADMIN_USER:-admin}"
EBOT_ADMIN_PASS="${EBOT_ADMIN_PASS:-password}"
EBOT_ADMIN_MAIL="${EBOT_ADMIN_MAIL:-admin@ebot}"

TOORNAMENT_SECRET="${TOORNAMENT_SECRET:-}"
TOORNAMENT_API_KEY="${TOORNAMENT_API_KEY:-}"
TOORNAMENT_PLUGIN_KEY="${TOORNAMENT_PLUGIN_KEY:-azertylol}"

# for usage with docker-compose
while ! nc -z $MYSQL_HOST $MYSQL_PORT; do sleep 3; done

if [ ! -f .installed ]
then
    php symfony configure:database "mysql:host=${MYSQL_HOST};dbname=${MYSQL_DB}" $MYSQL_USER $MYSQL_PASS
    php symfony doctrine:insert-sql
    php symfony guard:create-user --is-super-admin admin@ebot $EBOT_ADMIN_USER $EBOT_ADMIN_PASS

    # manage config
    sed -i "s|log_match:.*|log_match: ${LOG_FOLDER}/log_match|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|log_match_admin:.*|log_match_admin: ${LOG_FOLDER}/log_match_admin|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|demo_path:.*|demo_path: ${DEMO_FOLDER}|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|default_rules:.*|default_rules: ${DEFAULT_RULES}|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|ebot_ip:.*|ebot_ip: ${EBOT_IP}|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|ebot_port:.*|ebot_port: ${EBOT_PORT}|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|demo_download:.*|demo_download: ${DEMO_DOWNLOAD}|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|toornament_id:.*|toornament_id: ${TOORNAMENT_ID}|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|toornament_secret:.*|toornament_secret: ${TOORNAMENT_SECRET}|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|toornament_api_key:.*|toornament_api_key: ${TOORNAMENT_API_KEY}|" $EBOT_WEB_HOME/config/app_user.yml
    sed -i "s|toornament_plugin_key:.*|toornament_plugin_key: ${TOORNAMENT_PLUGIN_KEY}|" $EBOT_WEB_HOME/config/app_user.yml

    touch .installed
fi

php symfony cc

apache2-foreground
