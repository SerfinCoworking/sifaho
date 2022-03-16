class PermissionModule < ApplicationRecord

  include PgSearch::Model

  has_many :permissions

  validates :name, uniqueness: true
  validates_presence_of :name

  pg_search_scope :search_name,
    against: :name,
    :using => {
      :tsearch => { :prefix => true } # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  filterrific(
    default_filter_params: { sorted_by: 'name_desc' },
    available_filters: [
      :search_name,
      :sorted_by
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^name_/s
      # Ordenamiento por fecha de creación en la BD
      order("permission_modules.name #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def permissions_build(user, sector)
    permissions.where
               .not(id: user.permission_users.where(sector: sector)
               .collect(&:permission_id)).map { |permission|
                 user.permission_users.build(sector: sector, permission: permission)
               }
    user.permission_users
        .select { |permission_user| 
          permission_user if sector.present? && permission_user.sector_id == sector.id && permission_user.permission.permission_module_id == self.id 
        }
        .sort_by { |item| [item.permission.name] }
  end
end