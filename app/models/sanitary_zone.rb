class SanitaryZone < ApplicationRecord
  belongs_to :state
  has_many :departments
  has_many :establishments
  has_many :users, through: :establishments
  has_many :cities, through: :departments

  validates :name, presence: true, length: { minimum: 2 }
  validates :state, presence: true
  
  filterrific(
    default_filter_params: { sorted_by: 'nombre_desc' },
    available_filters: [
      :sorted_by,
      :search_name,
    ]
  )
  
  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^nombre_/s
      reorder("sanitary_zones.name #{ direction }")
    when /^departamentos_/
      left_joins(:departments)
      .group(:id)
      .reorder("COUNT(departments.id) #{ direction }")
    when /^establecimientos_/
      left_joins(:establishments)
      .group(:id)
      .reorder("COUNT(establishments.id) #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
end
