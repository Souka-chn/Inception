# DEV_DOC.md — Developer Documentation · Inception

Technical documentation for developers and evaluators of the Inception project.

---

## Prerequisites

The following tools must be installed inside the **Linux VM**:

| Tool           | Recommended version | Purpose                             |
| -------------- | ------------------- | ----------------------------------- |
| Docker         | ≥ 24.x              | Containerization                    |
| Docker Compose | ≥ v2.x              | Service orchestration               |
| Make           | ≥ 4.x               | Automation                          |
| `sudo`         | —                   | Creating directories under `/home/` |

### DNS Mapping (VM only)

Add the following entry to `/etc/hosts` inside the VM:

```text
127.0.0.1 schernan.42.fr
```

---

## Configuration

### `.env` File

Location: `srcs/.env` (excluded from the Git repository through `.gitignore`)

Available variables:

```env
DOMAIN_NAME=schernan.42.fr

MYSQL_DATABASE=wordpress_db
MYSQL_USER=schernan_user
MYSQL_PASSWORD=secure_db_pass_2024
MYSQL_ROOT_PASSWORD=super_root_pass_2024

WP_ADMIN_USER=schernan_boss          # ⚠️ MUST NOT contain "admin"
WP_ADMIN_PASSWORD=boss_secret_pass123
WP_ADMIN_EMAIL=schernan@student.1337.ma

WP_USER=normal_user
WP_USER_PASSWORD=normal_user_pass123
WP_USER_EMAIL=normal_user@student.1337.ma

FTP_USER=schernan
FTP_PASS=ftp_secure_pass1337
```

---

## Build and Start

```bash
make up
```

### What `make up` does

1. `mkdir -p /home/schernan/data/portainer` — creates the Portainer persistence directory.
2. `mkdir -p /home/schernan/data/mariadb` — creates the MariaDB persistence directory.
3. `mkdir -p /home/schernan/data/wordpress` — creates the WordPress persistence directory.
4. `docker compose -f ./srcs/docker-compose.yml up -d --build` — builds all images and starts the containers.

> The first build may take several minutes because packages, WP-CLI, and the Portainer binary need to be downloaded.

---

## Service Management

| Command       | Action                                               |
| ------------- | ---------------------------------------------------- |
| `make up`     | Build and start all services                         |
| `make down`   | Stop all containers cleanly                          |
| `make clean`  | Stop containers and remove images and volumes        |
| `make fclean` | Full reset — also removes `/home/schernan/data/*`    |
| `make re`     | Run `fclean` followed by `up` for a complete rebuild |

---

## Service Architecture

### Network

The project uses a single Docker bridge network:

```text
inception_network
```

All containers communicate using **container/service names** through Docker's internal DNS.

Only port **443** is exposed to the host.

### Volumes

Named volumes use `driver_opts` to map Docker volumes to real directories on the host:

```yaml
mariadb_volume:
  driver: local
  driver_opts:
    type: none
    device: /home/schernan/data/mariadb
    o: bind
```

This approach complies with the 42 requirements: **direct bind mounts in `docker-compose.yml` are not used**, while named volumes configured with `driver_opts` are allowed.

### Data Persistence

| Service   | Volume             | Host path                       |
| --------- | ------------------ | ------------------------------- |
| MariaDB   | `mariadb_volume`   | `/home/schernan/data/mariadb`   |
| WordPress | `wordpress_volume` | `/home/schernan/data/wordpress` |
| Portainer | `portainer_data`   | `/home/schernan/data/portainer` |

---

## Service Details

### NGINX (`srcs/requirements/nginx/`)

* Base image: `debian:bookworm`
* Generates a self-signed RSA 2048-bit TLS certificate during the build
* Listens only on port 443 using TLSv1.2 and TLSv1.3
* Routes `.php` requests to `wordpress:9000` through FastCGI
* Proxies `/resume`, `/adminer`, and `/portainer/` to the corresponding bonus services

### MariaDB (`srcs/requirements/mariadb/`)

* Base image: `debian:bookworm`
* `setup.sh` initializes the database, user, and root password **only if** `${MYSQL_DATABASE}` does not already exist
* Uses `exec mysqld_safe` as PID 1
* Listens on `0.0.0.0:3306`, accessible only through the internal Docker network

### WordPress (`srcs/requirements/wordpress/`)

* Base image: `debian:bookworm`
* PHP 8.2-FPM + WP-CLI
* `setup.sh` waits for MariaDB to become ready before installing WordPress
* Installs and automatically activates the `redis-cache` plugin
* Uses `exec /usr/sbin/php-fpm8.2 -F` as PID 1

### Redis (`srcs/requirements/bonus/redis/`)

* Provides object caching for WordPress
* Protected mode is disabled because the service is isolated inside the internal Docker network

### Adminer (`srcs/requirements/bonus/adminer/`)

* Web interface for managing the MariaDB database
* Runs PHP's built-in web server on port 8080

### FTP (`srcs/requirements/bonus/ftp/`)

* Uses vsftpd with a user created from environment variables
* Passive mode uses ports 40000–40005
* Root directory: `/var/www/html/wordpress`
* Shares the WordPress volume to access the same WordPress files

### Portainer (`srcs/requirements/bonus/portainer/`)

* Official Portainer binary downloaded during the image build
* Supports amd64 and arm64 architectures
* Accessible through `/portainer/` via the NGINX reverse proxy

### Static Website (`srcs/requirements/bonus/static_site/`)

* Uses lighttpd to serve a portfolio page on port 80
* Accessible through:

```text
https://schernan.42.fr/resume
```

---

## Critical 42 Requirements

| Requirement                       | Implementation                                                   |
| --------------------------------- | ---------------------------------------------------------------- |
| PID 1 with `exec`                 | All entrypoints end with `exec <daemon>`                         |
| No `tail -f`                      | No usage in any startup script                                   |
| No `latest` tag                   | All images use `debian:bookworm`                                 |
| No passwords in Dockerfiles       | Credentials are provided through `.env` environment variables    |
| WordPress admin without `"admin"` | `WP_ADMIN_USER=schernan_boss`                                    |
| Named volumes only                | `driver_opts` bind mounts are used inside named volumes          |
| `inception_network` bridge        | One Docker network is defined in Compose                         |
| Port 443 only                     | NGINX exposes only port 443                                      |
| TLSv1.2 / TLSv1.3                 | Configured with `ssl_protocols TLSv1.2 TLSv1.3;` in `nginx.conf` |

---

## Debugging

### View service logs

```bash
docker logs <service>
```

### Open an interactive shell inside a container

```bash
docker exec -it <service> bash
```

### Check Docker volumes

```bash
docker volume ls
docker volume inspect inception_wordpress_volume
```

### Test the database from the WordPress container

```bash
docker exec -it wordpress mariadb -h mariadb -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE
```
