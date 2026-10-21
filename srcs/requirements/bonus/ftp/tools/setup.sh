#!/bin/bash

if id "$FTP_USER" >/dev/null 2>&1; then
    echo "FTP user already exists!"
else
    useradd -m -d /var/www/html/wordpress "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    echo "FTP user created successfully!"
fi

usermod -aG www-data "$FTP_USER"
chown -R www-data:www-data /var/www/html/wordpress
chmod -R g+rwX /var/www/html/wordpress

mkdir -p /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty

exec vsftpd /etc/ftp.conf