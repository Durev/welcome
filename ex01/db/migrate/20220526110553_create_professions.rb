# frozen_string_literal: true

class CreateProfessions < ActiveRecord::Migration[6.1]

  def change
    create_table :professions do |t|
      t.string(:category_name, null: false)
    end
  end

end
