class FortainPen < ApplicationRecord

  # 品番が実質のID
  self.primary_key = "product_number"

  validates :name, presence: true
  validates :price, presence: true
  validates :niv_type, presence: true
  validates :product_number, presence: true, uniqueness: true
end