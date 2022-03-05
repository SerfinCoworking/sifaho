class UnifyProduct < ApplicationRecord
  include PgSearch::Model
  include EnumTranslation
  enum status: { pending: 0, merged: 1 }

  # Relationships
  belongs_to :origin_product, class_name: 'Product'
  belongs_to :target_product, class_name: 'Product'

  # Delegations
  delegate :code, :name, :unity_name, :area_name, :description, :observation, :snomed_concept_id, :snomed_term, :status,
           :snomed_fsn, :snomed_semantic_tag, :snomed_concept,  to: :origin_product, prefix: :origin, allow_nil: true
  delegate :code, :name, :unity_name, :area_name, :description, :observation, :snomed_concept_id, :snomed_term, :status,
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

  def apply
    origin_product.chronic_prescription_products.each { |chron_pres| chron_pres.update_column('product_id', target_product.id) }
    origin_product.original_chronic_prescription_products.each { |orig_chron_pres| orig_chron_pres.update_column('product_id', target_product.id) }
    origin_product.inpatient_prescription_products.each { |inp_pre| inp_pre.update_column('product_id', target_product.id) }
    origin_product.external_order_products.each do |ext_ord|
      # Check if target product was already loaded
      unless ext_ord.order.order_products.where(product_id: target_product_id).present?
        ext_ord.update_column('product_id', target_product.id)
      end
    end
    origin_product.external_order_product_templates.each { |ext_ord_tmp| ext_ord_tmp.update_column('product_id', target_product.id) }
    origin_product.internal_order_products.each do |int_ord|
      # Check if target product was already loaded
      unless int_ord.order.order_products.where(product_id: target_product_id).present?
        int_ord.update_column('product_id', target_product.id)
      end
    end
    origin_product.internal_order_product_templates.each { |int_ord_tmp| int_ord_tmp.update_column('product_id', target_product.id) }
    origin_product.outpatient_prescription_products.each { |out_pre_prod| out_pre_prod.update_column('product_id', target_product.id) }
    origin_product.receipt_products.each { |rec_prod| rec_prod.update_column('product_id', target_product.id) }
    origin_product.internal_order_product_reports.each { |int_rep| int_rep.update_column('product_id', target_product.id) }
    origin_product.monthly_consumption_reports.each { |month_rep| month_rep.update_column('product_id', target_product.id) }
    origin_product.patient_product_reports.each { |pat_rep| pat_rep.update_column('product_id', target_product.id) }
    origin_product.report_product_lines.each { |rep_line| rep_line.update_column('product_id', target_product.id) }
    origin_product.patient_product_state_reports.each { |pat_prod_rep| pat_prod_rep.update_column('product_id', target_product.id) }
    origin_product.lots.each { |lot| lot.update_column('product_id', target_product.id) }
    # origin_product.stocks.each { |stock| stock.update_column('product_id', target_product.id) } Don't merge stocks

    # Update stocks / lot_stocks
    origin_product.stocks.each do | stock_origin |
      # Find target stock by "target product" and with same sector as stock_origin or create new stock
      # with quantities in zero.
      target_stock = Stock.create_with( quantity: 0,
                                        total_quantity: 0,
                                        reserved_quantity: 0
                                      ).find_or_create_by(product_id: target_product.id, sector_id: stock_origin.sector_id)
      
      # Stock could be found with quantities, and we need sum with stock_origin quantities
      sum_quantity = target_stock.quantity + stock_origin.quantity
      sum_total_quantity = target_stock.total_quantity + stock_origin.total_quantity
      sum_reserved_quantity = target_stock.reserved_quantity + stock_origin.reserved_quantity

      target_stock.update_columns(quantity: sum_quantity, total_quantity: sum_total_quantity, reserved_quantity: sum_reserved_quantity)
      
      # finally, update each lot_stock of stock_origin, with target_stock.id
      stock_origin.lot_stocks.each do | lot_stock_origin |
        lot_stock_origin.update_column(:stock_id, target_stock.id)
      end
    end

    merged!
    origin_product.merged!
  end
end
