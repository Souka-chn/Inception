FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./tools/setup.sh /usr/local/bin/setup.sh
COPY ./conf/mariadb.cnf /etc/mysql/mariadb.conf.d/mariadb.cnf

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]
