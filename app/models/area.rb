class Area < ApplicationRecord
  include PgSearch

  # Relations
  belongs_to :parent, class_name: 'Area', optional: true
  has_many :subareas, class_name: 'Area', foreign_key: :parent_id, dependent: :destroy
  has_many :products
    
  # Validations
  validates_presence_of :name
  
  delegate :name, to: :parent, prefix: true, allow_nil: true

  # Scopes
  scope :main, -> { where(parent_id: nil) }

  pg_search_scope :search,
    against: [:name],
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.
  
  def self.filter(params)
    @areas = self.all
    @areas = params[:name].present? ? self.search( params[:name] ) : @areas
  end

  def all_nested_products
    @all_products = self.products
    self.subareas.each do |subarea|
      @all_products += subarea.products
    end
    return @all_products
  end
end
