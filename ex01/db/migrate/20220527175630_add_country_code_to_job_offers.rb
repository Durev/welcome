# frozen_string_literal: true

class AddCountryCodeToJobOffers < ActiveRecord::Migration[6.1]

  def change
    change_table :job_offers do |t|
      t.string(:country_code, null: true)
    end
  end

end
