# frozen_string_literal: true

require "#{__dir__}/../application"

class JobOffer < ActiveRecord::Base

  extend Geocoder::Model::ActiveRecord

  CONTINENTS = [
    "Africa",
    "Asia",
    "Europe",
    "North America",
    "Oceania",
    "South America",
  ].freeze

  belongs_to :profession, optional: true

  # `geocoded` and `not_geocded` scopes are provided by geocoder
  scope :not_reverse_geocoded, -> { geocoded.where(country_code: nil) }

  reverse_geocoded_by :office_latitude, :office_longitude do |obj, results|
    if geo = results.first
      obj.country_code = geo.country_code
      obj.continent = ::COUNTRIES.dig(obj.country_code, "continent_name")
    end
  end

end
