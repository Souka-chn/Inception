FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y php8.2-fpm php8.2-cli \
    php8.2-mysql \
    mariadb-client \
    wget tar && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php

WORKDIR /var/www/html

COPY ./tools/setup.sh /usr/local/bin/setup.sh
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
