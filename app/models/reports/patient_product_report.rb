class PatientProductReport < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :product

  delegate :code, :name, to: :product, prefix: :product

  validates_presence_of :product, :since_date, :to_date, :created_by
end
