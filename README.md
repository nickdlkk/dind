# dind with ssh server

This image provides docker-in-docker with ssh access.  
You can use docker/docker-compose in this container.

**This project uses the root user and no longer uses ordinary users.**

Execute the following command.

```bash
docker-compose up -d
```

## Configuration

You can change the anything by `docker-compose.yml`

**Port**

SSH is running with the port 2022 in this container.  
You can change the port.

```yml
ports:
  - "2022:2022"
```

**Volume**

'dind' uses /var/lib/docker.  
You can change the volume and recommended modify this path to SSD.

**unraid** recommends using the original path of the SSD directly and skipping the system cache.

```yml
volumes:
  - /mnt/disk4/appdata/mydind/docker:/var/lib/docker
```

`/web` path is my development path, save all project code
```yml
volumes:
  - /mnt/user/projects/web:/web
```

`./ssh` path is container ssh configuration path.
You can save your authorization key here

```yml
volumes:
  - ./ssh:/root/.ssh
```

`/root/.vscode-server` is the main program and cache content of vscode server.

```yml
volumes:
  - ./vscode-server:/root/.vscode-server
```

