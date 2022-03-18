# frozen_string_literal: true

require 'yaml'
require 'securerandom'

# DMPTool specific Rake tasks
namespace :init do
  desc 'Generates a unique credentials.yml.example file'
  task hub: :environment do
    yaml = YAML.load_file('/usr/src/app/config/credentials.yml.enc.example')

    yaml['secret_key_base'] = SecureRandom.hex(64)

    yaml['devise']['secret_key'] = SecureRandom.hex(64)
    yaml['devise']['pepper'] = SecureRandom.hex(64)

    yaml['database']['host'] = ENV['DB_HOST']
    yaml['database']['username'] = ENV['DB_USERNAME']
    yaml['database']['password'] = ENV['DB_PASSWORD']

    yaml['ezid']['username'] = ENV['EZID_USERNAME']
    yaml['ezid']['password'] = ENV['EZID_PASSWORD']
    yaml['ezid']['shoulder'] = ENV['EZID_SHOULDER']
    yaml['ezid']['hosting_institution'] = ENV['EZID_HOSTING_INSTITUTION']

    yaml['orcid']['client_id'] = ENV['ORCID_CLIENT_ID']
    yaml['orcid']['client_secret'] = ENV['ORCID_CLIENT_SECRET']

    File.open('/usr/src/app/config/credentials.yml.seed', 'w') { |file| YAML.dump(yaml, file) }
  end
end
