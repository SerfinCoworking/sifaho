class ExternalOrderProductReport < ApplicationRecord
  include Reportable

  belongs_to :created_by, class_name: 'User'
  belongs_to :sector

  delegate :establishment_name, to: :sector

  validates_presence_of :since_date, :to_date
end
