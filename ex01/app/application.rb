# frozen_string_literal: true

require "active_record"

Dir["#{__dir__}/models/*.rb"].each { |path| require path }

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/development.sqlite3"
)
