class AddColumnFortainPens < ActiveRecord::Migration[5.2]
  def up
    add_column :fortain_pens, :product_number , :string, null: false
  end

  def down
    remove_column :fortain_pens, :product_number , :string, null: false
  end
end
