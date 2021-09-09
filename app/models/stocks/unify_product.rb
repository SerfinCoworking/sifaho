class UnifyProduct < ApplicationRecord
  include PgSearch
  include EnumTranslation
  enum status: { pending: 0, applied: 1 }

  # Relationships
  belongs_to :origin_product, class_name: 'Product'
  belongs_to :target_product, class_name: 'Product'

  # Delegations
  delegate :code, :name, :unity_name, :area_name, :description, :observation, :snomed_concept_id, :snomed_term,
           :snomed_fsn, :snomed_semantic_tag, :snomed_concept,  to: :origin_product, prefix: :origin, allow_nil: true
  delegate :code, :name, :unity_name, :area_name, :description, :observation, :snomed_concept_id, :snomed_term,
           :snomed_fsn, :snomed_semantic_tag, :snomed_concept,  to: :target_product, prefix: :target, allow_nil: true

  # Validations
  validate :different_origin_product_than_target

  filterrific(
    default_filter_params: { sorted_by: 'creado_asc' },
    available_filters: %i[search_origin_product search_target_product for_statuses sorted_by]
  )

  # Scopes
  pg_search_scope :search_origin_product,
                  associated_against: { origin_product: %i[code name] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_target_product,
                  associated_against: { target_product: %i[code name] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^creado_/s
      # Ordenamiento por fecha de creación en la BD
      order("unify_products.created_at #{direction}")
    when /^producto_origen_/
      # Ordenamiento por nombre de producto origen
      reorder("origin_products.name #{direction}").joins(:origin_product)
    when /^producto_destino_/
      # Ordenamiento por nombre de producto destino
      reorder("target_products.name #{direction}").joins(:target_product)
    when /^estado_/
      # Ordenamiento por nombre de estado
      reorder("unify_products.status #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
      ['Producto origen (menor primero)', 'producto_origen_asc'],
      ['Producto origen (mayor primero)', 'producto_origen_desc'],
      ['Producto destino (menor primero)', 'producto_destino_asc'],
      ['Producto destino (mayor primero)', 'producto_destino_desc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Estado (z-a)', 'estado_desc'],
      ['Creado (a-z)', 'creado_asc'],
      ['Creado (z-a)', 'creado_desc']
    ]
  end

  def self.options_for_status
    [
      ['Pendiente', 'pending', 'secondary'],
      ['Aplicado', 'applied', 'success']
    ]
  end

  scope :for_statuses, ->(values) do
    return all if values.blank?

    where(status: statuses.values_at(*Array(values)))
  end

  def different_origin_product_than_target
    errors.add(:target_product_id, 'El producto destino no puede ser igual al origen') if origin_product_id == target_product_id
  end
end
