class LotProvenance < ApplicationRecord

  # Relations
  has_many :lots, foreign_key: :provenance_id

  # Validations
  validates :name, presence: true
end
