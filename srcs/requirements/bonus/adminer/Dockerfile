FROM debian:bookworm

RUN apt-get update && apt-get install -y php php-mysql wget

RUN rm -rf /var/www/html/index.html

RUN mkdir -p /var/www/html/adminer

RUN wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" -O /var/www/html/adminer/index.php

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
