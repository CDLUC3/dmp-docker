cd /usr/src/app && bundle install

bundle exec rails -v

# Master key
if [ -f /usr/src/app/config/master.key ] && [ -f /tmp/backups/hub_master.key ]
then
  echo 'Using existing ./config/master.key'
else
  if [ -f /tmp/backups/hub_master.key ]
  then
    echo 'Linking master.key from /tmp/backups to ./config/credentials/docker.key'
    if [ -f /usr/src/app/config/credentials/docker.key ]
    then
      # remove the broken symbolic link
      rm /usr/src/app/config/credentials/docker.key
    fi
    ln -s /tmp/backups/hub_master.key /usr/src/app/config/credentials/docker.key
  else
    echo 'Generating docker.key and storing in /tmp/backups'
    # Place a copy of thee file in the backups to retain if volume is deleted!
    bundle exec rails secret | cut -c -32 | tail -1 > /tmp/backups/hub_master.key
    echo 'Linking hub_master.key from /tmp/backups to ./config/credentials/docker.key'
    ln -s /tmp/backups/hub_master.key /usr/src/app/config/credentials/docker.key
  fi
fi

# Encrypted credentials
if [ -f /usr/src/app/config/credentials/docker.yml.enc ] && [ -f /tmp/backups/hub_credentials.yml.enc ]
then
  echo 'Using existing ./config/credentials/docker.yml.enc'
else
  if [ -f /tmp/backups/hub_credentials.yml.enc ]
  then
    echo 'Linking docker.yml.enc to /tmp/backups/hub_credentials.yml.enc'
    if [ -f /usr/src/app/config/credentials/docker.yml.enc ]
    then
      # remove the broken symbolic link
      rm /usr/src/app/config/credentials/docker.yml.enc
    fi
    ln -s /tmp/backups/hub_credentials.yml.enc /usr/src/app/config/credentials/docker.yml.enc
  else
    echo 'Generating docker.yml.enc and storing in /tmp/backups'
    cp /usr/src/app/scripts/init.rake /usr/src/app/lib/tasks/init.rake
    # Replace some values in an initializer that try to reference the non-existent credentials file
    cp /usr/src/app/config/initializers/constants.rb /usr/src/app/config/initializers/constants.rb.bak
    sed -i "s/Rails.application.credentials.dmphub\[:helpdesk_email\]/ENV['HELPDESK_EMAIL']/g" /usr/src/app/config/initializers/constants.rb
    sed -i "s/Rails.application.credentials.ezid\[:landing_page_url\]/ENV['EZID_LANDING_PAGE_URL']/g" /usr/src/app/config/initializers/constants.rb
    sed -i "s/Rails.application.credentials.ezid\[:api_base_url\]/ENV['EZID_API_BASE_URL']/g" /usr/src/app/config/initializers/constants.rb

    cp /usr/src/app/config/initializers/devise.rb /usr/src/app/config/initializers/devise.rb.bak
    sed -i "s/Rails.application.credentials.devise\[:secret_key\]/ENV['DEVISE_SECRET_KEY']/g" /usr/src/app/config/initializers/devise.rb
    sed -i "s/Rails.application.credentials.devise\[:pepper\]/ENV['DEVISE_PEPPER']/g" /usr/src/app/config/initializers/devise.rb
    sed -i "s/Rails.application.credentials.orcid\[:client_id\]/ENV['ORCID_CLIENT_ID']/g" /usr/src/app/config/initializers/devise.rb
    sed -i "s/Rails.application.credentials.orcid\[:client_secret\]/ENV['ORCID_CLIENT_SECRET']/g" /usr/src/app/config/initializers/devise.rb
    sed -i "s/Rails.application.credentials.orcid\[:member\]/ENV['ORCID_MEMBER']/g" /usr/src/app/config/initializers/devise.rb
    sed -i "s/Rails.application.credentials.orcid\[:sandbox\]/ENV['ORCID_MEMBER']/g" /usr/src/app/config/initializers/devise.rb

    cp /usr/src/app/config/database.yml /usr/src/app/config/database.yml.bak
    sed -i "s/Rails.application.credentials.database\[:host\]/ENV['DB_HOST']/g" /usr/src/app/config/database.yml
    sed -i "s/Rails.application.credentials.database\[:username\]/ENV['DB_USERNAME']/g" /usr/src/app/config/database.yml
    sed -i "s/Rails.application.credentials.database\[:password\]/ENV['DB_PASSWORD']/g" /usr/src/app/config/database.yml
    sed -i "s/Rails.application.credentials.database\[:pool\]/16/g" /usr/src/app/config/database.yml

    # Generate the credentials file
    EDITOR='echo "$(cat /usr/src/app/config/credentials.yml.enc.example)" >' bundle exec rails credentials:edit -e docker
    bundle exec rails init:hub
    EDITOR='echo "$(cat /usr/src/app/config/credentials.yml.seed)" >' bundle exec rails credentials:edit -e docker
    # rm /usr/src/app/config/credentials.yml.seed
    mv /usr/src/app/config/initializers/constants.rb.bak /usr/src/app/config/initializers/constants.rb
    mv /usr/src/app/config/initializers/devise.rb.bak /usr/src/app/config/initializers/devise.rb
    mv /usr/src/app/config/database.yml.bak /usr/src/app/config/database.yml
    echo 'Linking hub_credentials.yml.enc from /tmp/backups to ./config/credentials/docker.yml.enc'
    # Move the file to the backups dir and then link to it
    mv /usr/src/app/config/credentials/docker.yml.enc /tmp/backups/hub_credentials.yml.enc
    ln -s /tmp/backups/hub_credentials.yml.enc /usr/src/app/config/credentials/docker.yml.enc
  fi
fi
