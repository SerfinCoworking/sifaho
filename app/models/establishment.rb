class Establishment < ApplicationRecord
  include PgSearch

  # Relaciones
  has_many :sectors

  # SCOPES #--------------------------------------------------------------------
  pg_search_scope :search_name,
  against: :name,
  :using => {
    :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
  },
  :ignoring => :accents # Ignorar tildes.

  scope :where_not_id, lambda { |an_id|
    where.not(id: [*an_id])
  }
end
