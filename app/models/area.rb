class Area < ApplicationRecord
  include PgSearch

  # Relations
  belongs_to :parent, class_name: 'Area', optional: true
  has_many :subareas, class_name: 'Area', foreign_key: :parent_id, dependent: :destroy

  
  # Validations
  validates_presence_of :name
  
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
end
