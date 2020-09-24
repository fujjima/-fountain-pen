class FortainPen < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true
  validates :niv_type, presence: true
end