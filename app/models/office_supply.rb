class OfficeSupply < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  # Relaciones
  has_many :office_supply_categorizations
  has_many :categories, :through => :office_supply_categorizations
  belongs_to :sector

  # Estados
  enum status: { activo: 0, inactivo: 1, mantenimiento: 2 }

  # Validaciones
  validates_presence_of :name, :quantity, :status, :remit_code
  validates_uniqueness_of :remit_code, conditions: -> { with_deleted }

  filterrific(
    default_filter_params: { sorted_by: 'creado_desc' },
    available_filters: [
      :search_supply,
      :search_description,
      :with_status,
      :sorted_by
    ]
  )

  pg_search_scope :search_supply,
    against: :name,
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_description,
    against: :description,
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^nombre_/
      # Ordenamiento por nombre de insumo
      order("office_supplies.name #{ direction }")
    when /^descripcion_/
      # Ordenamiento por descripción
      order("office_supplies.description #{ direction }")
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("office_supplies.status #{ direction }")
    when /^creado_/
      # Ordenamiento por la fecha de creación
      order("office_supplies.created_at #{ direction }")
    when /^modificado_/
      # Ordenamiento por la fecha de modificación
      order("office_supplies.updated_at #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_status, lambda { |a_status|
    where('office_supplies.status = ?', a_status)
  }

  def self.sector(a_sector)
    where(sector: a_sector)
  end

  # Label del estado para vista.
  def status_label
    if self.activo?; return 'success';
    elsif self.inactivo?; return 'danger';
    elsif self.mantenimiento?; return 'warning'; end
  end

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Activo', 0, 'success'],
      ['Inactivo', 1, 'danger'],
      ['Mantenimiento', 2, 'warning'],
    ]
  end

  def self.status_to_change
    [
      ['Activo', 'activo', 'success'],
      ['Inactivo', 'inactivo', 'danger'],
      ['Mantenimiento', 'mantenimiento', 'warning'],
    ]
  end
end
