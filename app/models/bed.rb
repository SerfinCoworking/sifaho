class Bed < ApplicationRecord
  belongs_to :bedroom

  validates :name, presence: true, uniqueness: true
end
