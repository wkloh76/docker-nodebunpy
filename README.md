# Docker Deploy NodeBunPy

![Static Badge](https://img.shields.io/badge/License-Mulan_PSL_v2-_)
![Static Badge](https://img.shields.io/badge/NodeJS-V24_.18_.0-_)
![Static Badge](https://img.shields.io/badge/BunJS-V1_.3_.14-_)
![Static Badge](https://img.shields.io/badge/ElectronJS-V42_.4_.1-_)
![Static Badge](https://img.shields.io/badge/Python3-Latest-__?style=flat)
![Static Badge](https://img.shields.io/badge/OS-Alpine_3.20-_?style=flat)

## Overview

A Docker-based deployment toolkit that supports **Node.js**, **Bun**, and **Python 3** runtimes on Alpine Linux. It is designed to work seamlessly with [OricommJS](https://github.com/oricommjs) (the default framework), but can accommodate other frameworks with minor `docker-compose.yml` adjustments.

### Key Features

- **Multi-runtime support** — Run projects with Node.js, Bun, or Python 3
- **Alpine-based images** — Minimal image footprint
- **Unified compose workflow** — Build and deploy from a single `docker-compose.yml`
- **Configurable entry points** — Set `INTERPRETER` and `MAIN_APP` to switch runtimes and scripts

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Git

### 1. Clone and configure

```bash
git clone <repo-url>
cd docker-nodebunpy
cp .env.example .env
```

Edit `.env` to set your desired versions:

| Variable | Description     | Default                   |
| -------- | --------------- | ------------------------- |
| `IMG`    | Image name      | `alpine-nodebunpy-deploy` |
| `TAG`    | Node.js version | `24.18.0`                 |
| `ARG1`   | Bun version     | `1.3.14`                  |

### 2. Build the image

```bash
docker compose build
```

### 3. Deploy the container

```bash
docker compose up -d
```

The container runs `/app/app.js` (Node.js) or `/app/app.py` (Python 3) by default. Mount your project code to `/app`:

```yaml
volumes:
  - ./myapp:/app
```

## Configuration

### Environment Variables

| Variable        | Description                         | Default             |
| --------------- | ----------------------------------- | ------------------- |
| `PUID`          | User ID                             | `1000`              |
| `PGID`          | Group ID                            | `1000`              |
| `TZ`            | Timezone                            | `Asia/Kuala_Lumpur` |
| `RUN_MODE`      | `debug` or `production`             | `debug`             |
| `RUN_ENGINE`    | Runtime engine                      | `webnodejs`         |
| `USER_NAME`     | Container username                  | `node`              |
| `USER_PASSWORD` | Container password                  | `node1234`          |
| `INTERPRETER`   | Runtime: `node`, `bun`, or `python` | `bun`               |
| `MAIN_APP`      | Entry script (e.g. `app.py`)        | `app.js`            |
| `PYVENV`        | Enable Python virtual environment   | `NO`                |

### Ports

| Container   | Host        |
| ----------- | ----------- |
| `3000-3001` | `9820-9821` |

---

## Usage Scenarios

### Scenario 1 — OricommJS with Node.js (Default)

```yaml
nodebun-deploy:
  image: "${IMG}:${TAG}-${ARG1}"
  container_name: nodebun_deploy
  environment:
    - PUID=1000
    - PGID=1000
    - TZ=Asia/Kuala_Lumpur
    - RUN_MODE=debug
    - RUN_ENGINE=webnodejs
    - USER_PASSWORD=test1234
    - USER_NAME=test
    - PYVENV=NO
  volumes:
    - ./testapp/app:/app
  working_dir: /app
  ports:
    - 9820-9821:3000-3001
  shm_size: "2gb"
  restart: unless-stopped
```

### Scenario 2 — OricommJS with Bun

```yaml
nodebun-deploy:
  image: "${IMG}:${TAG}-${ARG1}"
  container_name: nodebun_deploy
  environment:
    - PUID=1000
    - PGID=1000
    - TZ=Asia/Kuala_Lumpur
    - RUN_MODE=debug
    - RUN_ENGINE=webnodejs
    - USER_PASSWORD=test1234
    - USER_NAME=test
    - PYVENV=NO
    - INTERPRETER=bun
  volumes:
    - ./testapp/app:/app
  working_dir: /app
  ports:
    - 9820-9821:3000-3001
  shm_size: "2gb"
  restart: unless-stopped
```

### Scenario 3 — Python with a custom entry script

```yaml
nodebun-deploy:
  image: "${IMG}:${TAG}-${ARG1}"
  container_name: nodebun_deploy
  environment:
    - PUID=1000
    - PGID=1000
    - TZ=Asia/Kuala_Lumpur
    - RUN_MODE=debug
    - RUN_ENGINE=webnodejs
    - USER_PASSWORD=test1234
    - USER_NAME=test
    - PYVENV=NO
    - INTERPRETER=python
    - MAIN_APP=app.py
  volumes:
    - ./testapp/app:/app
  working_dir: /app
  ports:
    - 9820-9821:3000-3001
  shm_size: "2gb"
  restart: unless-stopped
```

### Python Virtual Environment

Set `PYVENV=YES` to activate a Python virtual environment. Ensure your project includes a `requirements.txt` file — packages will be installed on first run.

## Docker Daemon Setup

If you need to pull images from a private registry, configure the Docker daemon:

1. Create `/etc/docker/daemon.json`:

   ```json
   { "insecure-registries": ["xxx.xxx.xxx.xxx:port"] }
   ```

2. Restart Docker:

   ```bash
   sudo systemctl stop docker.socket && sudo systemctl stop docker.service
   sudo systemctl start docker.socket && sudo systemctl start docker.service
   ```

## Git Configuration

```bash
git config user.name "My Name"
git config user.email "myemail@example.com"
```

## Utilities

### FIGlet — Terminal Banners

Create large ASCII text banners in the terminal:

```bash
figlet -w 60 'ALPINE BUNJS' > ./BANNER
```

### Change User Password (Non-interactive)

```bash
echo "<user>:<password>" | sudo chpasswd
```

## Project Structure

```
├── Dockerfile          # Multi-stage build (Alpine + Node.js + Bun + Python/uv)
├── docker-compose.yml  # Build + deploy services
├── .env.example        # Default environment variables
├── scripts/
│   ├── app.js          # Default Node.js entry point
│   ├── app.py          # Default Python entry point
│   └── install_module.js
├── root/               # Base filesystem overlay
└── README.md
```

## Reference

- [LinuxServer.io](https://github.com/linuxserver) — Excellent community providing Docker images and build source code
- [Alpine 3.22 base image](https://github.com/linuxserver/docker-baseimage-alpine/releases/tag/3.22-b9b6866a-ls3)
- [SSH Warning Banner & MOTD](https://www.tecmint.com/ssh-warning-banner-linux/)
- [Crafting Terminal Text with FIGlet](https://labex.io/tutorials/linux-crafting-striking-terminal-text-with-figlet-272383)
- [Check if a variable is set in bash](https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash)
