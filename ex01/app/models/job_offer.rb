# frozen_string_literal: true

require "#{__dir__}/../application"

class JobOffer < ActiveRecord::Base

  extend Geocoder::Model::ActiveRecord

  reverse_geocoded_by :office_latitude, :office_longitude do |obj, results|

    if geo = results.first
      obj.country_code = geo.country_code
      obj.continent = ::COUNTRIES[obj.country_code]["continent_name"]
    end
  end

  # `geocoded` and `not_geocded` scopes are provided by geocoder
  scope :not_reverse_geocoded, -> { geocoded.where(country_code: nil) }

  after_validation :reverse_geocode

end
