class RenameTypeColumnToFortainPens < ActiveRecord::Migration[5.2]
  def change
    rename_column :fortain_pens, :type, :niv_type
  end
end
