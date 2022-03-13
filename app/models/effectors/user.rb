class User < ApplicationRecord
  rolify
  include PgSearch::Model
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable, :database_authenticatable
  devise :ldap_authenticatable, authentication_keys: [:username]

  # Relaciones
  has_many :permission_users
  has_many :permissions, through: :permission_users
  has_many :user_sectors
  has_many :sectors, through: :user_sectors
  belongs_to :sector, optional: true
  has_many :establishments, through: :sectors
  has_one :profile, dependent: :destroy
  has_one :professional, dependent: :destroy
  has_many :external_order_comments
  has_many :reports, dependent: :destroy
  has_many :permission_requests, dependent: :destroy
  has_many :inpatient_prescription_products

  accepts_nested_attributes_for :profile, :professional
  accepts_nested_attributes_for :permission_users, allow_destroy: true

  validates :username, presence: true, uniqueness: true

  after_create :create_profile # Comment in development

  # Delegaciones
  delegate :full_name, :first_name, :dni, :email, to: :profile
  delegate :name, :applicant_internal_orders, :applicant_external_orders, :provider_internal_orders,
           :provider_external_orders, :establishment_short_name,
           to: :sector, prefix: :sector, allow_nil: true
  delegate :establishment_name, to: :sector, allow_nil: true
  delegate :establishment, to: :sector
  delegate :full_info, to: :professional, prefix: true, allow_nil: true

  def create_profile
    #first_name = Devise::LDAP::Adapter.get_ldap_param("Test", "givenname").first # Uncomment in test
    if Rails.env.test?
      profile = Profile.new(user: self, first_name: 'Test', last_name: 'Reimann', email: 'reimann@example.com', dni: 00001111)
    else
      # Comment in production
      first_name = Devise::LDAP::Adapter.get_ldap_param(username, 'givenname').first.encode('Windows-1252',
                                                                                            invalid: :replace,
                                                                                            undef: :replace)
      last_name = Devise::LDAP::Adapter.get_ldap_param(username, 'sn').first.encode('Windows-1252',
                                                                                    invalid: :replace,
                                                                                    undef: :replace)
      email = Devise::LDAP::Adapter.get_ldap_param(username, 'mail').present? ? Devise::LDAP::Adapter.get_ldap_param(username, 'mail').first : 'Sin email'
      dni = Devise::LDAP::Adapter.get_ldap_param(username, 'uid').present? ? Devise::LDAP::Adapter.get_ldap_param(username, 'uid').first : 'Sin DNI'
      profile = Profile.new(user: self, first_name: first_name, last_name: last_name, email: email, dni: dni)
    end

    profile.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'profile-placeholder.jpg')),
                          filename: 'profile-placeholder.jpg', content_type: 'image/jpg')
    profile.save!
  end

  after_save :verify_profile

  def verify_profile
    unless profile.present?
      create_profile # Comment in development
    end
    unless sector.present?
      if sectors.present?
        self.sector = sectors.first
        self.save
      end
    end
  end

  def valid_password?(password)
    Devise::Encryptor.compare(self.class, encrypted_password, password)
  end

  # hack for remember_token
  def authenticatable_salt
    Digest::SHA1.hexdigest(username)[0,29]
  end

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: %i[
      search_username
      search_by_fullname
      sorted_by
    ]
  )

  pg_search_scope :search_username,
                  against: :username,
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_by_fullname,
                  associated_against: { profile: %i[first_name last_name] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("users.created_at #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_sector_id, lambda { |an_id|
    where(sector_id: [*an_id])
  }

  def full_name
    if profile.present?
      profile.full_name
    else
      username
    end
  end

  def name_and_sector
    "#{full_name} | #{sector.name}"
  end

  def sector_and_establishment
    "#{sector_name} #{establishment_name}"
  end

  def has_permission?(permissions_target)
    permissions.joins(:permission_users).where(name: permissions_target, 'permission_users.sector_id': sector_id).any?
  end
end
