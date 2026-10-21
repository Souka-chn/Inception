FROM debian:bookworm

RUN apt-get update && apt-get install -y lighttpd

COPY ./conf/index.html /var/www/html/resume/index.html

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
