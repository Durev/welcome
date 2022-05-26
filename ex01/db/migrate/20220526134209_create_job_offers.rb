# frozen_string_literal: true

class CreateJobOffers < ActiveRecord::Migration[6.1]

  def change
    create_table :job_offers do |t|
      t.references(:profession, foreign_key: true, index: true, null: true)
      t.decimal(:office_latitude, precision: 8, scale: 6, null: true)
      t.decimal(:office_longitude, precision: 9, scale: 6, null: true)
      t.string(:continent, null: true)
    end
  end

end
