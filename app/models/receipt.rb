class Receipt < ApplicationRecord
  include PgSearch

  belongs_to :provider_sector, class_name: 'Sector'
  belongs_to :applicant_sector, class_name: 'Sector'
  belongs_to :created_by, class_name: 'User', optional: true
  has_many :receipt_products
  has_many :supplis, through: :receipt_products

  # Validaciones
  validates_presence_of :provider_sector, :applicant_sector, :code
  validates :receipt_products, :presence => {:message => "Debe agregar almenos 1 producto"}
  validates_associated :receipt_products
  validates_uniqueness_of :code

  # Atributos anidados
  accepts_nested_attributes_for :receipt_products,
    :reject_if => :all_blank,
    :allow_destroy => true

  pg_search_scope :search_code,
    :against => :code,
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.
end
