class User < ApplicationRecord
  rolify
  include PgSearch
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
  devise :database_authenticatable, :authentication_keys => [:username]

  # Relaciones
  has_many :user_sectors
  has_many :sectors, :through => :user_sectors
  belongs_to :sector
  has_one :profile, :dependent => :destroy
  has_one :professional, :dependent => :destroy

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :professional

  after_create :create_profile

  def create_profile
    Profile.create(user: self)
  end

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_username,
      :sorted_by
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("users.created_at #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_sector_id, lambda { |an_id|
    where(sector_id: [*an_id])
  }
 
  pg_search_scope :search_username,
  against: :username,
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  def full_name
    if self.profile.last_name?
      self.profile.full_name
    else
      self.username
    end
  end

  def name_and_sector
    self.full_name+" | "+self.sector.name
  end

  def sector_name
    self.sector.name
  end

  def establishment_name
    self.sector.establishment_name
  end
end
