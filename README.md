# dmptool-docker

Docker support for the DMPTool and DMPHub services.

## Environment setup

Add the following shortcut aliases to your `~/.zshrc` or `~/bash_profile` (optional):
```
alias dc=docker-compose
alias dcr_tool='docker-compose run tool /bin/bash'
alias dce_tool='docker-compose exec tool /bin/bash'
alias dcr_hub='docker-compose run hub /bin/bash'
alias dce_hub='docker-compose exec hub /bin/bash'
```
### Clone the repositories
Clone the DMPTool repository: `cd ./services/tool && git clone git@github.com:CDLUC3/dmptool.git src`
Clone the DMPHub repository: `cd ./services/hub && git clone git@github.com:CDLUC3/dmphub.git src`

### Build the containers

Run: `dc build`

### Initial setup

Create your own `.env` file for each service and update the values as needed (for example your DB
credentials)
```
cp ./services/tool/.env.example ./services/tool/.env
cp ./services/hub/.env.example ./services/hub/.env
```

If you have existing key and credentials files you would like to use with the application, you can simply place them in the `./backups` directory. They should be named appropriately: `hub_master.key`, `hub_credentials.yml.enc`, `tool_master.key` and `tool_credentials.yml.enc`.

If you have an existing database you would like to use, place it into the `./backups` directory and name it appropriately for the service. A DMPTool database should end with `_tool.sql` and a DMPHub database should end with `_hub.sql`.

### Initialize the DMPTool

Then spin up the container and initialize the DMPTool by running `dcr_tool`. Once the container is up it will log you into the container where you should run:
```
# Initialize the Rails credentials. This will either use the existing tool_master.key and tool_credentials.yml.enc (by placing a symbolic link in the application config/) or will generate new ones based on the contents of your .env file.
./scripts/init_creds.sh

# You can then optionally verify that the values are correct (they should reflect the values in your .env)
EDITOR=vim bundle exec rails credentials:edit RAILS_ENV=development

# Initialize the DB. This will use the backup you provided in the ./backups directory or will create a new DB based on the application's `db/seeds.rb` file
./scripts/init_db.sh
```

Once complete, the hub_master.key and hub_credentials.yml.enc files will be placed into the `./backups` directory and a symbolic link added to the application's `config/` for each.

### Initialize the DMPHub

Then spin up the container and initialize the DMPHub by running `dcr_hub`. Once the container is up it will log you into the container where you should run:
```
# Initialize the Rails credentials. This will either use the existing tool_master.key and tool_credentials.yml.enc (by placing a symbolic link in the application config/) or will generate new ones based on the contents of your .env file.
./scripts/init_creds.sh

# You can then optionally verify that the values are correct (they should reflect the values in your .env)
EDITOR=vim bundle exec rails credentials:edit -e docker

# Initialize the DB. This will use the backup you provided in the ./backups directory or will create a new DB based on the application's `db/seeds.rb` file
./scripts/init_db.sh
```

Once complete, the hub_master.key and hub_credentials.yml.enc files will be placed into the `./backups` directory and a symbolic link added to the application's `config/` for each.

## Startup the DMPTool and DMPHub

To startup both services run `dc up`
To startup just the DMPTool run `dce_tool`
To startup just the DMPHub run `dce_hub`

## Helpful Docker commands

- Build the docker image: `dc build`
- See what containers are running and what ports they use `dc ps`
- Build and connect to the container (without starting it up): `dcr`
- Build and run the container: `dc up`
- Connect to the running container `dce`
- Remove any stale containers: `dc down --remove-orphans --rmi`
- For debugging your Docker build: `dc build --no-cache --progress=plain`
