# Docker Deploy NodeBunPy

![Static Badge](https://img.shields.io/badge/License-Mulan_PSL_v2-_)
![Static Badge](https://img.shields.io/badge/NodeJS-V20_.19_.4-_)
![Static Badge](https://img.shields.io/badge/BunJS-V1_.2_.20-_)
![Static Badge](https://img.shields.io/badge/ElectronJS-V34_.2_.0-_)
![Static Badge](https://img.shields.io/badge/Python3-Latest-__?style=flat)
![Static Badge](https://img.shields.io/badge/OS-Alpine_3.20-_?style=flat)

## Objectvie

- Design docker images which will able deploy the project in `NodeJS` , `BunJS` or `Python3` design.
- Project default framework is OricommJS which backend and frontend render html statement to browser. You can use other framework to support your project but the `docker-compose.yml` need to change a little bit.

- The docker-compose files combine both build and up containers feature in one files.

- Why choose Alpine OS because the images size will be small compare to other OS.

## Environment setup

### Docker deamon setup

- Create daemon file `/etc/docker/daemon.json` and content show as below
  ```
  {"insecure-registries":["xxx.xxx.xxx.xxx:port"]}
  ```
- Stop and start docker service from systemctl.

  ```
  sudo systemctl stop docker.socket && sudo systemctl stop docker.service

  sudo systemctl start docker.socket && sudo systemctl start docker.service
  ```

### Git

- git config user.name "My Name"

- git config user.email "myemail@example.com"

### figlet

- FIGlet is a utility for creating large characters out of ordinary screen characters. It's often used in terminal sessions to create eye-catching text, banners, or headers.

  ```
  Figlet -w 60  'ALPINE BUNJS' >> ./BANNER
  ```

## Take Noted

- Docker image building relies on `.env` files. So copy and paste ".env.example" and rename it to ".env". After that run the command "docker compose build" in the terminal with the same project. You can change the .env setting value yourself.
  ```
  nodebun-build:
    image: "${IMG}:${TAG}-${ARG1}"
    build:
      context: .
      dockerfile: ./Dockerfile
      args:
        NODE_VERSION: "${TAG}"
        BUN_VERSION: "${ARG1}"
  ```
- Run command `docker compose up -d` will establish deploy container.The script target to run is `app.js` or `app.py` files and container check the file exist in `/app` folder. If no will run default script `app.js` or `app.py` from `/scripts` folder base on the `INTERPRETER` value.

  ```
  nodebun-deploy:
      image: "${IMG}:${TAG}-${ARG1}"
      container_name: nodebun_deploy
      environment:
        - PUID=1000
        - PGID=1000
        - TZ=Asia/Kuala_Lumpur
        - RUN_MODE=debug # debug or production
        - RUN_ENGINE=webnodejs # webnodejs
        - USER_PASSWORD=node1234 # Allow to change
        - USER_NAME=node # Allow to change
        # - PYVENV=YES # Active python virtual environment service
        - INTERPRETER=node # Change runtime engine such as python,node and bun, default is bun
        # - MAIN_APP=app.js
      # volumes:
      #   - ./testapp/app:/app  # The source code point to /app directory
      working_dir: /app
      ports:
        - 9820-9821:3000-3001
      shm_size: "2gb"
      restart: unless-stopped
  ```

- The project will run and target to `app.js` or `app.py` file.
- Different senario the docker-compose setting will be change.

  1.  Default - Only support OricommJS framework run with node interpreter. The project code folder mount to /app. If want python virtual environment support , just change `PYVENV=YES` and make sure your project has `requirement.txt` file to install python packages during first time activate.

      ```
        nodebun-deploy:
        image: "${IMG}:${TAG}-${ARG1}"
        container_name: nodebun_deploy
        environment:
          - PUID=1000
          - PGID=1000
          - TZ=Asia/Kuala_Lumpur
          - RUN_MODE=debug # debug or production
          - RUN_ENGINE=webnodejs # webnodejs
          - USER_PASSWORD=node1234 # Allow to change
          - USER_NAME=node # Allow to change
          - PYVENV=NO # Active python virtual environment
        volumes:
          - ./testapp/app:/app  # The source code point to /app directory
        working_dir: /app
        ports:
          - 9820-9821:3000-3001
        shm_size: "2gb"
        restart: unless-stopped
      ```

  2.  OricommJS framework run with bun interpreter.

      ```
        nodebun-deploy:
        image: "${IMG}:${TAG}-${ARG1}"
        container_name: nodebun_deploy
        environment:
          - PUID=1000
          - PGID=1000
          - TZ=Asia/Kuala_Lumpur
          - RUN_MODE=debug # debug or production
          - RUN_ENGINE=webnodejs # webnodejs
          - USER_PASSWORD=node1234 # Allow to change
          - USER_NAME=node # Allow to change
          - PYVENV=NO # Active python virtual
          environment
          - INTERPRETER=bun # Change runtime engine such as python,node and bun, default is bun
        volumes:
          - ./testapp/app:/app  # The source code point to /app directory
        working_dir: /app
        ports:
          - 9820-9821:3000-3001
        shm_size: "2gb"
        restart: unless-stopped
      ```

  3.  For different framework project and different main script, assign the script file for `MAIN_APP` and other interpreter like ptyhon.

      ```
        nodebun-deploy:
        image: "${IMG}:${TAG}-${ARG1}"
        container_name: nodebun_deploy
        environment:
          - PUID=1000
          - PGID=1000
          - TZ=Asia/Kuala_Lumpur
          - RUN_MODE=debug # debug or production
          - RUN_ENGINE=webnodejs # webnodejs
          - USER_PASSWORD=node1234 # Allow to change
          - USER_NAME=node # Allow to change
          - PYVENV=NO # Active python virtual
          environment
          - INTERPRETER=python # Change runtime engine such as python,node and bun, default is bun
          - MAIN_APP=app.py
        volumes:
          - ./testapp/app:/app  # The source code point to /app directory
        working_dir: /app
        ports:
          - 9820-9821:3000-3001
        shm_size: "2gb"
        restart: unless-stopped
      ```

# Reference

- Change the password without prompt message box

  ```
  echo <user>:<password>> | sudo chpasswd
  ```

- [linueserver.io](https://github.com/linuxserver) is great community which provide allow of user docker images and also source code for build docker images. I am learn a lot form here.

- [baseimage alpine 3.22-b9b6866a-ls3](https://github.com/linuxserver/docker-baseimage-alpine/releases/tag/3.22-b9b6866a-ls3)

- [How to Set a Custom SSH Warning Banner and MOTD in Linux](https://www.tecmint.com/ssh-warning-banner-linux/)
- [Crafting Striking Terminal Text with FIGlet](https://labex.io/tutorials/linux-crafting-striking-terminal-text-with-figlet-272383)

- [how to check if a variable is set in bash](https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash)
