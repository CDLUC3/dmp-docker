# frozen_string_literal: true

require 'yaml'
require 'securerandom'

# DMPTool specific Rake tasks
namespace :init do
  # We sent the maDMP PRs over to DMPRoadmap after they had been live in DMPTool for some time
  # This script moves the re3data URLs which we original stored in the :identifiers table
  # over to the repositories.uri column
  desc 'Generates a unique credentials.yml.example file'
  task tool: :environment do
    yaml = YAML.load_file('/usr/src/app/config/credentials.yml.example')

    yaml['secret_key_base'] = SecureRandom.hex(64)

    yaml['dmproadmap']['devise_secret'] = SecureRandom.hex(64)
    yaml['dmproadmap']['devise_pepper'] = SecureRandom.hex(64)

    yaml['dmproadmap']['dragonfly_secret'] = SecureRandom.hex(64)

    File.open('/usr/src/app/config/credentials.yml.seed', 'w') { |file| YAML.dump(yaml, file) }

  end
end
