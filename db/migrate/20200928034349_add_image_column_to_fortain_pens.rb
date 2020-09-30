class AddImageColumnToFortainPens < ActiveRecord::Migration[5.2]
  def up
    add_column :fortain_pens, :image, :string
  end

  def down
    remove_column :fortain_pens, :image, :string
  end
end
