# dmptool-docker-dev

Docker support for a development environment that runs both the DMPTool and DMPHub services.

## Environment setup

Add the following shortcut aliases to your `~/.zshrc` or `~/bash_profile` (optional):
```
alias dc=docker-compose
alias dcr_tool='docker-compose run tool /bin/bash'
alias dce_tool='docker-compose exec tool /bin/bash'
alias dcr_hub='docker-compose run hub /bin/bash'
alias dce_hub='docker-compose exec hub /bin/bash'
```
### Clone the repository and the submodules
Clone this repository: `git clone `
Initialize the submodules: `git submodule init`
Pull down the latest code for each submodule: `git submodule update --remote`

Note that the submodule will always pull down the latest commit for the branch specified in the `.gitmodules` file. If this repo's last update for it's submodules pointed to a different branch then a `git status` will indicate that there are outstanding changes to the submodule ref. For example if another user created a branch in the DMPTool and updated this repo to point to the ref for that branch, you will see something like the following after you run `git submodule update --remote`:
```
> git diff
diff --git a/services/tool/dmptool b/services/tool/dmptool
index 3a84b73..02af3f0 160000
--- a/services/tool/dmptool
+++ b/services/tool/dmptool
@@ -1 +1 @@
-Subproject commit 3a84b73523c8feb35e9be7a8bff64f0f83a0f5c4
+Subproject commit 02af3f025bbf3822cda5fa01cbea69248f51c0b1
```

If this happens its best to either contact the owner of the latest change and have them revert the update to the submodule ref in this repo OR update your .gitmodules file to point to that branch if you both need to work on it and then rerun `git suubmodule update --remote`. For example:
```
[submodule "services/hub/dmphub"]
	path = services/hub/dmphub
	url = git@github.com:CDLUC3/dmphub.git
	branch = main
[submodule "services/tool/dmptool"]
	path = services/tool/dmptool
	url = git@github.com:CDLUC3/dmptool.git
	branch = new-branch-name
```

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

- To startup both services run `dc up`
- To startup just the DMPTool run `dcr_tool`
- To startup just the DMPHub run `dcr_hub`

Once the containers are running (verifiable by running `dc ps`) you can run `dce_tool` and `dce_hub` to connect to the container where you can then run command line tasks (e.g. `bin/rails housekeeping:monthly_maintenance`)

## Submodules

Both the DMPTool and DMPHub code are handled as [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) here. You can interact with them as if they were normally cloned git repositories (e.g. switching branches, pulling changes, and editing, adding or deleting files)

### Making changes to submodule code
To make changes to one of these repositories just do the following (assuming you want to change something for the dmptool):
- Navigate to the submodule directory: `cd ./services/tool/dmptool/`
- Open the appropriate file(s) in the submodule directory in your favorite editor and make your changes (e.g. ./services/tool/dmptool/app/controllers/users_controller.rb)
-  commit your changes and push them to the remote GitHub repository as you normally would `git commit -am "my note on what was changed" && git push origin my_branch_name`
- Navigate back to this repositories root directory and check to make sure that it detects that changes were made: `cd ../../.. && git status`
  - You should see something like this: `modified:   services/tool/dmptool (modified content)`
  - If you then run `git submodule summary` you will see the list of commit messages (e.g. `> fixed bug #123`)
- Update this repository in GitHub to point the new refs for the submodule: `git commit -am 'updated dmptool submodule' && git push origin main`

### Syncing submodules with the latest
In the event that you suspect the submodule has changed and you just want to pull in the latest commit (for the branch defined in the `.gitmodules` file) you can run: `git submodule update --remote`

### Working in branches within a submodule
If you are making a significant number of changes and want to create a separate branch then you can do so in the appropriate submodule directory (e.g. `cd ./services/tool/dmptool && git checkout -b my-branch-name`) and then continue to make your changes as you normally would and commit/push those changes to the parent repository (e.g. from within the dmptool directory `git commit -am "fixed some bugs" && git push origin my-branch-name`).

Note that you now need to be thoughtful about the way you proceed with regard to this repository. If you update the ref this repository points to without first updating the `.gitmodules` file to point to your 'my-branch-name' branch, it can create problems for other developers.

To prevent this you should either review and merge your branch into main instead of updating this repo's ref to the submodule OR update the branch name in the `.gitmodules` file. This is only recommended if you will be collaborating with other developers on the branch coce, or it is a feature that will take some time to finish. For example:
```
[submodule "services/hub/dmphub"]
	path = services/hub/dmphub
	url = git@github.com:CDLUC3/dmphub.git
	branch = main
[submodule "services/tool/dmptool"]
	path = services/tool/dmptool
	url = git@github.com:CDLUC3/dmptool.git
	branch = my-branch-name
  ```

## Helpful Docker commands

- Build the docker image: `dc build`
- See what containers are running and what ports they use `dc ps`
- Build and connect to the container (without starting it up): `dcr`
- Build and run the container: `dc up`
- Connect to the running container `dce`
- Remove any stale containers: `dc down --remove-orphans --rmi`
- For debugging your Docker build: `dc build --no-cache --progress=plain`

## Helpful git submodule commands

- Pull down the latest commits: `git submodule update --remote`
- Check for changes to submodules in your local copy of the repo: `git submodule status`
- See the commit meesages for the changes to the submodules in your local copy of the repo: `git submodule summary`
