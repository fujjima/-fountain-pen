# frozen_string_literal: true

class FortainPen < ActiveRecord::Migration[5.2]
  def change
    create_table :fortain_pens do |t|
      t.string :name
      t.integer :price
      t.string :type
      t.timestamps
    end
  end
end
