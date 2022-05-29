# frozen_string_literal: true

require "#{__dir__}/../application"

class JobsCountService

  CONTINENTS = [nil, "Africa", "Asia", "Europe", "North America", "Oceania", "South America"].freeze

  CATEGORIES = ["Admin", "Business", "Conseil", "Créa", "Marketing / Comm'", "Retail", "Tech"].freeze

  def call
    rows = JobOffer
      .joins(:profession)
      .group(:continent, :category_name)
      .count

    hash = {}

    rows.each do |k, v|
      hash[k.first] ||= Hash.new(0)
      hash[k.first][k.last] = v
    end

    final_rows = []

    CONTINENTS.each do |continent|
      row = [continent]

      CATEGORIES.each do |category|
        row << hash[continent][category]
      end

      final_rows << row
    end

    final_rows
  end

end
