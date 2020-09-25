class AddUniqueIndexToFortainPen < ActiveRecord::Migration[5.2]
  def up
    add_index :fortain_pens, :product_number, unique: true
  end

  def down
    remove_index :fortain_pens, :product_number
  end
end
