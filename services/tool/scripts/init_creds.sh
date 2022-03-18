cd /usr/src/app && bundle install

bundle exec rails -v

# Master key
if [ -f /usr/src/app/config/master.key ] && [ -f /tmp/backups/tool_master.key ]
then
  echo 'Using existing ./config/master.key'
else
  if [ -f /tmp/backups/tool_master.key ]
  then
    echo 'Linking master.key from /tmp/backups to ./config/master.key'
    if [ -f /usr/src/app/config/master.key ]
    then
      # remove the broken symbolic link
      rm /usr/src/app/config/master.key
    fi
    ln -s /tmp/backups/tool_master.key /usr/src/app/config/master.key
  else
    echo 'Generating master.key and storing in /tmp/backups'
    # Place a copy of thee file in the backups to retain if volume is deleted!
    bundle exec rails secret | cut -c -32 | tail -1 > /tmp/backups/tool_master.key
    echo 'Linking tool_master.key from /tmp/backups to ./config/master.key'
    ln -s /tmp/backups/tool_master.key /usr/src/app/config/master.key
  fi
fi

# Encrypted credentials
if [ -f /usr/src/app/config/credentials.yml.enc ] && [ -f /tmp/backups/tool_credentials.yml.enc ]
then
  echo 'Using existing ./config/credentials.yml.enc'
else
  if [ -f /tmp/backups/tool_credentials.yml.enc ]
  then
    echo 'Linking credentials.yml.enc to /tmp/backups/tool_credentials.yml.enc'
    if [ -f /usr/src/app/config/credentials.yml.enc ]
    then
      # remove the broken symbolic link
      rm /usr/src/app/config/credentials.yml.enc
    fi
    ln -s /tmp/backups/tool_credentials.yml.enc /usr/src/app/config/credentials.yml.enc
  else
    echo 'Generating credentials.yml.enc and storing in /tmp/backups'
    cp /usr/src/app/scripts/init.rake /usr/src/app/lib/tasks/init.rake
    bundle exec rails init:tool
    EDITOR='echo "$(cat /usr/src/app/config/credentials.yml.seed)" >' bundle exec rails credentials:edit
    rm /usr/src/app/config/credentials.yml.seed
    echo 'Linking tool_credentials.yml.enc from /tmp/backups to ./config/credentials.yml.enc'
    # Move the file to the backups dir and then link to it
    mv /usr/src/app/config/credentials.yml.enc /tmp/backups/tool_credentials.yml.enc
    ln -s /tmp/backups/tool_credentials.yml.enc /usr/src/app/config/credentials.yml.enc
  fi
fi
