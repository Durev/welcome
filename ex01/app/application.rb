# frozen_string_literal: true

require "active_record"
require "csv"
require "geocoder"
require "standalone_migrations"
require "terminal-table"
require "yaml"

Dir["#{__dir__}/**/*.rb"].each { |path| require path }

DB_CONFIG = YAML.load_file("#{__dir__}/../db/config.yml").freeze

ActiveRecord::Base.establish_connection(
  adapter: DB_CONFIG["development"]["adapter"],
  database: DB_CONFIG["development"]["database"]
)

Geocoder.configure(
  lookup: :nominatim,
  timeout: 5
)

COUNTRIES = YAML.load_file("#{__dir__}/../config/countries.yml").freeze
