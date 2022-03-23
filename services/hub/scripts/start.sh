#!/bin/bash
set -e

# Ensure that we have a master.key and credentials.yml.enc
/usr/src/app/scripts/init_creds.sh

# Ensure that we have a DB!
/usr/src/app/scripts/init_db.sh

# Update the bundle if it's out of date
bundle check || bundle update

# Install all JS dependencies
yarn install

# Compile the assets
# bundle exec rails assets:precompile

# Startup the application
touch log/development.log
bundle exec puma -C config/puma.rb -p 3001
