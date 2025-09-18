# Hive Inception - Docker System Administration Project

![Docker](https://img.shields.io/badge/Docker-Blue) ![WordPress](https://img.shields.io/badge/WordPress-Blueviolet) ![MariaDB](https://img.shields.io/badge/MariaDB-Blue) ![Nginx](https://img.shields.io/badge/Nginx-Lightgrey)

## Overview

**Hive Inception** is a system administration exercise designed to teach Docker, container orchestration, and service connectivity.  
The goal is to virtualize multiple services inside a personal virtual machine and connect them using **Docker Compose**.

**Stack Overview:**

- **Nginx** – reverse proxy with TLSv1.2 or TLSv1.3
- **WordPress** – CMS with php-fpm (no Nginx)
- **MariaDB** – database service (no Nginx)
- **Volumes** – persistent storage for database and WordPress files
- **Docker network** – inter-container communication

---

## Requirements & Guidelines

- Must be done inside a **Virtual Machine**.
- All project files go in the `srcs` folder.
- A **Makefile** at the root directory must build all Docker images using `docker-compose.yml`.
- Docker images must be **built from scratch** (Alpine or Debian only; no pulling ready-made images).
- Containers must **restart automatically** if they crash.
- **Environment variables** must be used for credentials; `.env` file recommended.
- **Secrets** (passwords, API keys) must be stored securely and ignored by Git.
- Nginx container is the **only entrypoint** on port 443.
- Avoid hacky infinite loops (`tail -f`, `sleep infinity`, etc.) in Dockerfiles.

---

## Mandatory Setup

1. **Nginx Container** – TLS only, handles incoming traffic.
2. **WordPress Container** – php-fpm installed and configured (without Nginx).
3. **MariaDB Container** – database service only.
4. **Volumes**:
   - WordPress database
   - WordPress website files
5. **Docker Network** – interconnect containers.
6. **Database Users** – two users; admin user cannot contain `admin` or `administrator`.

**Directory Structure Example:**

