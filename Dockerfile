FROM joomla:latest

COPY create-user.php /create-user.php
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
