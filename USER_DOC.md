# USER_DOC.md — Inception User Guide

Welcome to the **Inception** infrastructure by **schernan**. This guide explains how to use and access the available services.

---

## Available Services

| Service             | Description                            | Access                              |
| ------------------- | -------------------------------------- | ----------------------------------- |
| **WordPress**       | Main blog / CMS                        | `https://schernan.42.fr`            |
| **WordPress Admin** | Administration panel                   | `https://schernan.42.fr/wp-admin`   |
| **Static Site**     | Personal resume                        | `https://schernan.42.fr/resume`     |
| **Adminer**         | Database management interface          | `https://schernan.42.fr/adminer`    |
| **Portainer**       | Docker management interface            | `https://schernan.42.fr/portainer/` |
| **MariaDB**         | Database (internal only)               | Port 3306 (internal network)        |
| **Redis**           | WordPress object cache (internal only) | Port 6379 (internal network)        |
| **FTP**             | WordPress file access                  | Port 21 + 40000-40005               |

> All web access is available through **HTTPS only** (port 443). The TLS certificate is self-signed, so your browser will display a security warning. This is expected.

---

## Starting the Services

From the project directory, run:

```bash
make up
```

Once started, wait approximately 30 seconds for all services to become operational.

---

## Stopping the Services

To stop the services, run:

```bash
make down
```

This safely stops all containers without deleting the stored data.

---

## Accessing the WordPress Website

1. Open your web browser.
2. Go to **`https://schernan.42.fr`**.
3. Accept the self-signed certificate warning.
4. You will be redirected to the WordPress website.

---

## Accessing WordPress Administration

Go to:

**`https://schernan.42.fr/wp-admin`**

The credentials are stored in:

```text
secrets/credentials.txt
```

Example:

```text
WordPress Admin: schernan_boss / boss_secret_pass123
WordPress User:  normal_user / normal_user_pass123
```

---

## Checking That the Services Are Running

Run:

```bash
docker ps
```

You should see 8 active containers:

* `nginx`
* `wordpress`
* `mariadb`
* `redis`
* `adminer`
* `ftp`
* `portainer`
* `static_site`

---

## Viewing Service Logs

To view the logs of a service:

```bash
docker logs <container_name>
```

For example:

```bash
docker logs wordpress
docker logs mariadb
```

---

## FTP Access

FTP can be used to access and transfer WordPress files.

* **Host:** `schernan.42.fr`
* **Port:** `21`
* **Username / Password:** defined in `srcs/.env` (`FTP_USER` / `FTP_PASS`)
* **Directory:** `/var/www/html/wordpress`

Use an FTP client such as **FileZilla** in passive mode.

The passive FTP ports are:

```text
40000-40005
```

---

## Persistent Data

Project data is preserved even after running `make down`.

The persistent data is stored in:

* **MariaDB:** `/home/schernan/data/mariadb`
* **WordPress:** `/home/schernan/data/wordpress`
* **Portainer:** `/home/schernan/data/portainer`

To remove **all project data**, use:

```bash
make fclean
```
# USER_DOC.md — Inception User Guide

Welcome to the **Inception** infrastructure by **schernan**. This guide explains how to use and access the available services.

---

## Available Services

| Service             | Description                            | Access                              |
| ------------------- | -------------------------------------- | ----------------------------------- |
| **WordPress**       | Main blog / CMS                        | `https://schernan.42.fr`            |
| **WordPress Admin** | Administration panel                   | `https://schernan.42.fr/wp-admin`   |
| **Static Site**     | Personal resume                        | `https://schernan.42.fr/resume`     |
| **Adminer**         | Database management interface          | `https://schernan.42.fr/adminer`    |
| **Portainer**       | Docker management interface            | `https://schernan.42.fr/portainer/` |
| **MariaDB**         | Database (internal only)               | Port 3306 (internal network)        |
| **Redis**           | WordPress object cache (internal only) | Port 6379 (internal network)        |
| **FTP**             | WordPress file access                  | Port 21 + 40000-40005               |

> All web access is available through **HTTPS only** (port 443). The TLS certificate is self-signed, so your browser will display a security warning. This is expected.

---

## Starting the Services

From the project directory, run:

```bash
make up
```

Once started, wait approximately 30 seconds for all services to become operational.

---

## Stopping the Services

To stop the services, run:

```bash
make down
```

This safely stops all containers without deleting the stored data.

---

## Accessing the WordPress Website

1. Open your web browser.
2. Go to **`https://schernan.42.fr`**.
3. Accept the self-signed certificate warning.
4. You will be redirected to the WordPress website.

---

## Accessing WordPress Administration

Go to:

**`https://schernan.42.fr/wp-admin`**

The credentials are stored in:

```text
secrets/credentials.txt
```

Example:

```text
WordPress Admin: schernan_boss / boss_secret_pass123
WordPress User:  normal_user / normal_user_pass123
```

---

## Checking That the Services Are Running

Run:

```bash
docker ps
```

You should see 8 active containers:

* `nginx`
* `wordpress`
* `mariadb`
* `redis`
* `adminer`
* `ftp`
* `portainer`
* `static_site`

---

## Viewing Service Logs

To view the logs of a service:

```bash
docker logs <container_name>
```

For example:

```bash
docker logs wordpress
docker logs mariadb
```

---

## FTP Access

FTP can be used to access and transfer WordPress files.

* **Host:** `schernan.42.fr`
* **Port:** `21`
* **Username / Password:** defined in `srcs/.env` (`FTP_USER` / `FTP_PASS`)
* **Directory:** `/var/www/html/wordpress`

Use an FTP client such as **FileZilla** in passive mode.

The passive FTP ports are:

```text
40000-40005
```

---

## Persistent Data

Project data is preserved even after running `make down`.

The persistent data is stored in:

* **MariaDB:** `/home/schernan/data/mariadb`
* **WordPress:** `/home/schernan/data/wordpress`
* **Portainer:** `/home/schernan/data/portainer`

To remove **all project data**, use:

```bash
make fclean
```

> This operation is **irreversible** and permanently deletes the stored data.