# frozen_string_literal: true

require "active_record"
require "geocoder"
require "yaml"

Dir["#{__dir__}/models/*.rb"].each { |path| require path }

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/development.sqlite3"
)

Geocoder.configure(
  lookup: :nominatim,
  timeout: 5
)

# load countries/continents matchup in constant
COUNTRIES = YAML.load_file("#{__dir__}/../config/countries.yml").freeze
