
echo 'Checking for DB named "dmphub"'
# Perform a check for tables. If none exist we need to seed the
if [ -z "$(mysql -uroot -hhub_db dmphub -e'SHOW TABLES;' -p$MYSQL_ROOT_PASSWORD)" ]
then
  echo 'No DB detected.'
  BACKUP="$(ls -Art /tmp/backups/ | grep '*_hub.sql' | tail -n 1)"

  if [ ! -z $BACKUP ] && [ -f $BACKUP ]
  then
    echo 'Building DB from contents of backup'
    echo $BACKUP
    mysql dmphub -htool_db -uroot -p$MYSQL_ROOT_PASSWORD < $BACKUP
  else
    echo 'No backup ending with "_hub.sql" found in /tmp/backups. Seeding DB'
    bundle exec rails db:drop RAILS_ENV=docker
    bundle exec rails db:create RAILS_ENV=docker
    bundle exec rails db:schema:load RAILS_ENV=docker
    bundle exec rails db:seed RAILS_ENV=docker
  fi
else
  echo 'DB already exists. No initialization required.'
fi
