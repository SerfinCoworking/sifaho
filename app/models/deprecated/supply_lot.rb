class SupplyLot < ApplicationRecord
  acts_as_paranoid
  include PgSearch::Model

  enum status: { vigente: 0, por_vencer: 1, vencido: 2, auditoria: 3 }

  # Callbacks
  before_validation :assign_constants
  after_validation :update_status
  before_update :update_status, if: :will_save_change_to_expiry_date?

  # Relaciones
  belongs_to :laboratory
  belongs_to :supply, -> { with_deleted }
  has_many :sector_supply_lots, -> { with_deleted }, dependent: :destroy
  has_many :sectors, through: :sector_supply_lots

  has_many :quantity_ord_supply_lots
  has_many :external_orders, -> { with_deleted },
    :through => :quantity_ord_supply_lots,
    :source => :quantifiable,
    :source_type => 'ExternalOrder'

  # Validaciones
  validates_presence_of :supply, :code, :supply_name, :lot_code, :laboratory
  validates :supply, 
    :uniqueness => { :scope => [:laboratory_id, :lot_code], 
    conditions: -> { with_deleted } }, # Paranoia
    unless: :expire?
  validates :supply,
    :uniqueness => { :scope => [:laboratory_id, :lot_code, :expiry_date],
    conditions: -> { with_deleted } }, # Paranoia 
    if: :expire?

  filterrific(
    default_filter_params: { sorted_by: 'insumo_asc' },
    available_filters: [
      :search_lot_code,
      :sorted_by,
      :with_status,
      :search_text,
      :search_laboratory,
      :expired_from
    ]
  )

  # SCOPES #--------------------------------------------------------------------

  pg_search_scope :search_lot_code,
  against: :lot_code,
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_text,
  against: [:code, :supply_name],
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_laboratory,
  associated_against: { :laboratory => :name},
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^creacion_/
      # Ordenamiento por fecha de recepción
      order("supply_lots.created_at #{ direction }")
    when /^lote_/
      # Ordenamiento por código de lote
      order("LOWER(supply_lots.lot_code) #{ direction }")
    when /^cod_ins_/
      # Ordenamiento por código de lote
      order("LOWER(supply_lots.code) #{ direction }")
    when /^insumo_/
      # Ordenamiento por nombre del insumo
      order("LOWER(supply_lots.supply_name) #{ direction }")
    when /^estado_/
      # Ordenamiento por estado del lote
      order("supply_lots.status #{ direction }")
    when /^cantidad_inicial_/
      # Ordenamiento por cantidad inicial del lote
      order("supply_lots.initial_quantity #{ direction }")
    when /^cantidad_/
      # Ordenamiento por cantidad actual del lote
      order("supply_lots.quantity #{ direction }")
    when /^expiracion_/
      # Ordenamiento por fecha de expiración
      order("supply_lots.expiry_date #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :expired_from, lambda { |reference_time|
    where('supply_lots.expiry_date >= ?', reference_time)
  }

  scope :with_status, lambda { |a_status|
    where('supply_lots.status = ?', a_status)
  }

  def self.lots_for_sector(a_sector)
    where(sector: a_sector)
  end

  scope :with_supply_id, lambda { |a_supply_id| 
    where('supply_id = ?', a_supply_id)
  }

  # Métodos públicos #----------------------------------------------------------

  # Disminuye la cantidad
  def decrement(a_quantity)
    if quantity < a_quantity
      raise ArgumentError, "Cantidad en stock insuficiente de lote N°"+self.id.to_s+" insumo "+self.supply_name
    elsif self.deleted?
      raise ArgumentError, "El lote N°"+self.id.to_s+" de "+self.supply_name+" se encuentra en la papelera"
    else
      self.quantity -= a_quantity
    end
  end

  # Retorna el porcentaje actual de stock
  def percent_stock
    self.quantity.to_f / self.initial_quantity  * 100 unless self.initial_quantity == 0
  end

  # Label de porcentaje de stock para vista.
  def quantity_label
    if self.percent_stock == 0 || self.percent_stock.nil?
      return 'danger'
    elsif self.percent_stock <= 30
      return 'warning'
    else
      return 'success'
    end
  end

  # Label del estado para vista.
  def status_label
    if self.vigente?
      return 'success'
    elsif self.por_vencer?
      return 'warning'
    elsif self.vencido?
      return 'danger'
    end
  end

  def format_expiry_date
    self.expiry_date.present? ? self.expiry_date.strftime('%m/%y') : 'No vence'
  end

  def laboratory_name
    self.laboratory.name
  end

  # Retorna el tipo de unidad
  def unity
    self.supply.unity
  end

  def needs_expiration?
    self.supply.needs_expiration?
  end

  # Update the status based on the expiry date
  def update_status_without_validate!
    unless self.auditoria?
      if self.expiry_date.present?
        if self.expiry_date < DateTime.now
          self.status = 'vencido'
        elsif expiry_date <= DateTime.now + 3.month
          self.status = 'por_vencer'
        elsif expiry_date > DateTime.now
          self.status = 'vigente'
        end
      end
    end
    self.save(validate: false)
  end

  # Métodos privados #----------------------------------------------------------

  private

  def expire?
    expiry_date.present?
  end
  
  # Se actualiza el estado de expiración sin guardar
  def update_status
    unless self.auditoria?
      if self.expiry_date.present?
        # If expired
        if self.expiry_date <= DateTime.now
          self.status = 'vencido'
          # If near_expiry
        elsif expiry_date < DateTime.now + 3.month && expiry_date > DateTime.now
          self.status = 'por_vencer'
          # If good
        elsif expiry_date > DateTime.now
          self.status = 'vigente'
        end
      end
    end
  end

  # Se asigna la cantidad inicial
  def assign_constants
    if self.initial_quantity.present? && self.initial_quantity < self.quantity # Si se edita y coloca una cantidad mayor a la inicial
      self.initial_quantity = self.quantity # Se vuelve a asignar la cantidad inicial
    end
    self. quantity = 0 unless self.quantity.present?
    self.initial_quantity = self.quantity unless initial_quantity.present?
    self.code = self.supply_id.to_s
    self.supply_name = self.supply.name
    self.date_received = DateTime.now unless date_received.present?
  end

  # Métodos de clase #----------------------------------------------------------

  # Opciones para ordenar por del filtro
  def self.options_for_sorted_by
   [
     ['Creación (desc)', 'creacion_desc'],
     ['Código de lote (asc)', 'lote_asc'],
     ['Código de insumo (asc)', 'cod_ins_asc'],
     ['Insumo (a-z)', 'insumo_asc'],
     ['Fecha expiración (asc)', 'expiracion_asc'],
   ]
  end

  # Opciones para estados del filtro
  def self.options_for_status
   [
     ['Todos', '', 'default'],
     ['Vigentes', 0, 'success'],
     ['Por vencer', 1, 'warning'],
     ['Vencidos', 2, 'danger'],
   ]
  end

  def self.update_status_to_all
    self.find_each do |lot|
      lot.update_status_without_validate!
    end
  end
end
