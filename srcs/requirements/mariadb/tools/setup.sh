#!/bin/bash
set -e

echo "Starting MariaDB setup..."

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

echo "Starting MariaDB temporarily..."
mysqld_safe --skip-networking &

mysqladmin --wait=30 ping --silent

echo "MariaDB is ready."

mariadb << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

echo "MariaDB setup completed."

mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "Starting MariaDB as main process..."

exec mysqld_safe