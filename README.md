*This project has been created as part of the 42 curriculum by schernan.*

# Inception

## Description

**Inception** is a system administration project from the 42 curriculum. Its purpose is to build a small web infrastructure using **Docker** and **Docker Compose**.

The project consists of several services running in separate containers. Each service has a specific responsibility and communicates with the other services through a dedicated Docker network.

The mandatory infrastructure is based on three main components:

* **NGINX** — HTTPS entry point and reverse proxy.
* **WordPress** — Web application and content management system.
* **MariaDB** — Database server used by WordPress.

The project also contains several bonus services:

* **Redis** — In-memory caching service.
* **Adminer** — Web interface for database administration.
* **FTP** — File transfer service for WordPress files.
* **Portainer** — Web interface for managing Docker resources.
* **Static Site** — Additional static website served through NGINX.

The main objective is to understand how independent services can be containerized, configured and connected together to form a functional infrastructure.

---

## Project Structure

The repository is organized by service, with the mandatory components separated from the bonus components.

```text
.
├── secrets
└── srcs
    └── requirements
        ├── bonus
        │   ├── adminer
        │   ├── ftp
        │   │   ├── conf
        │   │   └── tools
        │   ├── portainer
        │   ├── redis
        │   └── static_site
        │       └── conf
        ├── mariadb
        │   ├── conf
        │   └── tools
        ├── nginx
        │   └── conf
        └── wordpress
            ├── conf
            └── tools
```

Each service has its own configuration and, when necessary, initialization scripts.

This organization keeps each component independent and makes the infrastructure easier to maintain.

---

## Architecture

The services are connected through a private Docker network.

```text
                         HTTPS :443
                             |
                             v
                       +-------------+
                       |    NGINX    |
                       +------+------+
                              |
              +---------------+---------------+--------------+
              |               |               |              |
              v               v               v              v
        +-----------+   +-----------+   +-----------+   +-----------+
        | WordPress |   | Static Web|   |  Adminer  |   | Portainer |
        +-----+-----+   +-----------+   +-----+-----+   +-----------+
              |                               |
              v                               |
        +-----------+                         |
        |  MariaDB  |<------------------------+
        +-----+-----+
              |
              v
        +-----------+
        |   Redis   |
        +-----------+

        +-----------+  
        |    FTP    |      
        +-----------+       
```

NGINX is the public entry point of the infrastructure.

Client requests arrive through HTTPS and are forwarded to the appropriate internal service.

WordPress communicates with MariaDB for database operations and can communicate with Redis for caching.

The bonus services are also deployed as separate containers.

---

# Docker

## Why Docker is Used

Docker allows each application component to run inside its own isolated container.

Instead of installing NGINX, WordPress, MariaDB and the other services directly on the host system, each service is packaged with the dependencies and configuration it needs.

Docker Compose is used to describe the complete infrastructure and manage all containers together.

This provides several advantages:

* service isolation;
* reproducible deployment;
* independent configuration;
* easier maintenance;
* simpler service lifecycle management;
* controlled networking.

The containers communicate through a dedicated Docker network rather than using the host network.

---

# Virtual Machines vs Docker

A **Virtual Machine (VM)** emulates a complete computer and normally runs a complete guest operating system.

Docker containers take a different approach. Containers isolate applications and processes while sharing the Linux kernel of the host system.

| Virtual Machines                         | Docker                           |
| ---------------------------------------- | -------------------------------- |
| Each VM runs a complete operating system | Containers share the host kernel |
| Higher CPU and RAM consumption           | Generally lower resource usage   |
| Larger disk requirements                 | Smaller storage footprint        |
| Longer startup time                      | Fast startup                     |
| Hardware-level virtualization            | Process and namespace isolation  |

For Inception, Docker is more suitable because the project requires several independent services without requiring a complete operating system for every service.

---

# Secrets vs Environment Variables

## Environment Variables

Environment variables are appropriate for configuration values that do not need to be treated as highly confidential.

Examples include:

```text
DOMAIN_NAME=schernan.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
```

They allow configuration to be changed without rebuilding the image.

## Secrets

Secrets are intended for sensitive information.

Examples include:

* passwords;
* database credentials;
* authentication information;
* private keys.

Keeping sensitive values in separate secret files prevents credentials from being directly embedded in Dockerfiles or application configuration.

### Comparison

| Secrets                                    | Environment Variables                 |
| ------------------------------------------ | ------------------------------------- |
| Intended for sensitive information         | Mainly intended for configuration     |
| Suitable for passwords and credentials     | Suitable for non-sensitive settings   |
| Kept separately from normal configuration  | Easily passed through Compose         |
| Reduces accidental exposure of credentials | Convenient for changing configuration |

The project uses environment variables for general configuration and separate secrets for sensitive credentials.

---

# Docker Network vs Host Network

## Docker Network

The project uses a dedicated Docker network.

Containers can communicate using their service names.

For example:

```text
wordpress -> mariadb:3306
```

Docker provides internal DNS resolution, so WordPress does not need to know the IP address of the MariaDB container.

A private Docker network provides:

* service isolation;
* internal DNS;
* controlled communication;
* reduced exposure of internal services.

## Host Network

With host networking, the container uses the host machine's network stack directly.

This reduces network isolation and can create port conflicts with applications already running on the host.

For this reason, the project uses a dedicated Docker network instead of host networking.

---

# Docker Volumes vs Bind Mounts

Containers have a writable filesystem layer, but data stored only there is tied to the lifetime of the container.

Important application data therefore needs persistent storage.

## Docker Volumes

Docker volumes are storage areas managed by Docker.

They are useful for persistent application data such as:

```text
MariaDB
└── Database files

WordPress
└── Website files
```

If a container is removed and recreated, the data stored in its volume can remain available.

## Bind Mounts

A bind mount maps a specific directory from the host filesystem into the container.

For example:

```text
Host
/home/user/data/mariadb
        |
        v
Container
/var/lib/mysql
```

The host controls the location of the data.

### Comparison

| Docker Volumes                             | Bind Mounts                             |
| ------------------------------------------ | --------------------------------------- |
| Managed by Docker                          | Managed directly by the user            |
| Docker determines the storage location     | User specifies the host path            |
| Convenient for persistent application data | Convenient when host access is required |
| Less dependent on host filesystem layout   | Depends on the host directory structure |

The project uses persistent storage for WordPress and MariaDB so that important data is not lost when containers are recreated.

---

# Services

## NGINX

NGINX is the entry point of the web infrastructure.

Its main responsibilities are:

* accepting HTTPS connections;
* handling TLS;
* serving the configured certificates;
* receiving client requests;
* acting as a reverse proxy;
* forwarding requests to the appropriate service.

The public HTTPS connection is terminated by NGINX.

---

## WordPress

WordPress is the main web application.

It provides the website and its content management functionality.

WordPress communicates with MariaDB to store and retrieve application data.

It can also use Redis as a caching layer.

---

## MariaDB

MariaDB is the relational database used by WordPress.

It stores persistent information such as:

* users;
* posts;
* pages;
* website settings;
* other WordPress data.

The database files are stored in persistent storage rather than only inside the container.

---

## Redis

Redis is an in-memory data store used as a cache.

Caching can reduce repeated database operations and improve application performance by temporarily storing frequently requested information.

---

## Adminer

Adminer provides a web-based interface for interacting with the MariaDB database.

It can be used to inspect databases, browse tables and execute SQL queries.

---

## FTP

The FTP service provides a way to transfer files to and from the WordPress directory.

An authorized user can use FTP to manage website files remotely.

---

## Portainer

Portainer is a web-based management interface for Docker.

It provides a graphical way to inspect and manage:

* containers;
* images;
* networks;
* volumes.

---

## Static Site

The project contains an additional static website.

Unlike WordPress, it does not require a database.

The static content is served independently and made accessible through NGINX.

---

# Persistence

Containers should be considered replaceable.

Removing a container removes its writable filesystem layer, so application data that must survive container recreation cannot depend on that layer.

The project therefore uses persistent storage for important data.

The main persistent resources are:

```text
MariaDB
└── /var/lib/mysql
    └── Database data

WordPress
└── /var/www/html/wordpress
    └── Website files
```

This allows the services to be rebuilt or recreated without losing important application data.

---

# Instructions

## Requirements

The project requires:

* Linux or a Linux virtual machine;
* Docker;
* Docker Compose;
* Git;
* Make.

A Debian-based environment can be used for the project.

---

## Clone the Repository

Clone the project and enter its directory:

```bash
git clone <repository-url>
cd inception
```

---

## Configuration

Before starting the infrastructure, configure the required environment variables and secrets.

The domain used by the project is:

```text
schernan.42.fr
```

Sensitive passwords and credentials should remain outside the Git repository.

---

## Build and Run

The complete infrastructure can be built and started with:

```bash
make
```

Alternatively:

```bash
docker compose up --build
```

Docker Compose will build the required images and create the containers, network and persistent storage defined by the project.

---

## Verify the Containers

After starting the infrastructure:

```bash
docker ps
```

You should see the running services.

To display all containers, including stopped ones:

```bash
docker ps -a
```

---

## Access the Website

The main WordPress website is accessible through:

```text
https://schernan.42.fr
```

The project uses a self-signed TLS certificate, so the browser may display a certificate warning.

This warning is expected in the development environment.

---

## Stop the Infrastructure

Using the Makefile:

```bash
make down
```

Or directly with Docker Compose:

```bash
docker compose down
```

Persistent volumes are not removed simply by stopping or removing the containers.

---

# Useful Commands

### Display running containers

```bash
docker ps
```

### Display all containers

```bash
docker ps -a
```

### List Docker images

```bash
docker images
```

### List volumes

```bash
docker volume ls
```

### List networks

```bash
docker network ls
```

### Inspect a container

```bash
docker inspect <container_name>
```

### Access a running container

```bash
docker exec -it <container_name> sh
```

### Display service logs

```bash
docker compose logs
```

For an individual service:

```bash
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb
```

### Validate the Compose configuration

```bash
docker compose config
```

This command is useful for checking the final Compose configuration after environment variables and Compose settings have been processed.

---
## Resources

* [Architecture of Docker — GeeksforGeeks](https://www.geeksforgeeks.org/devops/architecture-of-docker/)
* [A Simple Documentation for Inception](https://purple-page-995.notion.site/A-simple-Documentation-for-inception-dd60c488201741b09f1ed64157245bdf)

---

## AI Usage

AI tools were used as a learning and assistance resource during the project.

They were used for:

* Helping understand some technical concepts.
* Assisting in writing the README and documentation.
* Debugging errors.

