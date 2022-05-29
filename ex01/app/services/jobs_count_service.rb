# frozen_string_literal: true

require "#{__dir__}/../application"

# The responsibility of this service object is to fetch the count of offers per category and per continent
# and to serialize the result in a format than can be fed to the terminal-table interface
class JobsCountService

  def self.call
    new.send(:call)
  end

  private

  def call
    JobOffer::CONTINENTS.each_with_object([]) do |continent, arr|
      row = [continent]

      Profession::CATEGORIES.each do |category|
        row << count_per_continent_per_category[continent][category]
      end

      arr << row
    end
  end

  def query_result
    @_query_result ||= JobOffer
      .joins(:profession)
      .group(:continent, :category_name)
      .count
  end

  def count_per_continent_per_category
    @_count_per_continent_per_category ||=
      query_result.each_with_object({}) do |(k, v), hash|
        hash[k.first] ||= Hash.new(0)
        hash[k.first][k.last] = v
      end
  end

end
