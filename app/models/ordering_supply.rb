class OrderingSupply < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  enum order_type: { despacho: 0, solicitud_abastecimiento: 1, recibo: 2 }
  enum status: { solicitud_auditoria: 0, solicitud_enviada: 1, proveedor_auditoria: 2, 
    proveedor_aceptado: 3, provision_en_camino: 4, provision_entregada: 5, recibo_auditoria: 6,
    recibo_realizado: 7, anulado: 8 }
 
  # Relaciones
  belongs_to :applicant_sector, class_name: 'Sector'
  belongs_to :provider_sector, class_name: 'Sector'
  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :accepted_by, class_name: 'User', optional: true
  belongs_to :sent_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :sent_request_by, class_name: 'User', optional: true
  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :supplies, -> { with_deleted }, :through => :quantity_ord_supply_lots
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots
  has_many :movements, class_name: "OrderingSupplyMovement"

  # Validaciones
  validates_presence_of :applicant_sector
  validates_presence_of :provider_sector
  validates_presence_of :quantity_ord_supply_lots
  validates_presence_of :remit_code
  validates_associated :quantity_ord_supply_lots
  validates_associated :supplies
  validates_associated :sector_supply_lots
  validates_uniqueness_of :remit_code, conditions: -> { with_deleted }

  accepts_nested_attributes_for :supplies
  accepts_nested_attributes_for :sector_supply_lots
  accepts_nested_attributes_for :quantity_ord_supply_lots,
    reject_if: ->(qosl){ qosl['supply_id'].blank? },
    :allow_destroy => true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_applicant,
      :search_provider,
      :search_lot_code,
      :search_supply,
      :sorted_by,
      :date_received_at,
    ]
  )

  pg_search_scope :search_lot_code,
  :associated_against => { :supply_lots => :lot_code },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply,
  :associated_against => { applicant_sector: [:name, :code] },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_applicant,
  :associated_against => { profile: [:last_name, :first_name], :responsable => :username },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_provider,
  :associated_against => { profile: [:last_name, :first_name], :responsable => :username },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("ordering_supplies.created_at #{ direction }")
    when /^responsable_/
      # Ordenamiento por nombre de responsable
      order("LOWER(responsable.username) #{ direction }").joins("INNER JOIN users as responsable ON responsable.id = ordering_supplies.responsable_id")
    when /^sector_/
      # Ordenamiento por nombre de sector
      order("sectors.name #{ direction }").joins(:sector)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("ordering_supplies.status #{ direction }")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de insumo solicitado
      order("supply_lots.supply_name #{ direction }").joins(:supply_lots)
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("ordering_supplies.date_received #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_at, lambda { |reference_time|
    where('ordering_supplies.date_received >= ?', reference_time)
  }

  scope :with_sector_id, lambda { |an_id|
    where(sector_id: [*an_id])
  }

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Sector (a-z)', 'sector_asc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recibido (asc)', 'recibido_desc'],
    ]
  end

  def self.applicant(a_sector)
    where(applicant_sector: a_sector)
  end

  def self.provider(a_sector)
    where(provider_sector: a_sector)
  end

  def sum_to?(a_sector)
    return self.applicant_sector == a_sector
  end

  def with_sector?(a_sector)
    if self.provision_en_camino? || self.recibo_realizado? || self.provision_entregada?
      return self.applicant_sector == a_sector || self.provider_sector == a_sector
    end
  end

  # Cambia estado a "en camino" y descuenta la cantidad a los insumos
  def send_order(a_user)
    if self.proveedor_aceptado?
      if self.quantity_ord_supply_lots.exists?
        if self.validate_quantity_lots
          self.quantity_ord_supply_lots.each do |qosl|
            qosl.decrement
          end
        end
      else
        raise ArgumentError, 'No hay insumos solicitados en el pedido'
      end # End check if quantity_ord_supply_lots exists
      self.sent_by = a_user
      self.sent_date = DateTime.now
      self.provision_en_camino!
    else
      raise ArgumentError, 'El pedido está en'+ self.status.split('_').map(&:capitalize).join(' ')
    end 
  end

  # Cambia estado del pedido a "Aceptado" y se verifica que hayan lotes
  def accept_order(a_user)
    if proveedor_auditoria?
      if self.quantity_ord_supply_lots.present?
        self.accepted_date = DateTime.now
        self.accepted_by = a_user
        self.proveedor_aceptado!
      else
        raise ArgumentError, 'No hay insumos solicitados en el pedido'
      end
    else
      raise ArgumentError, 'El pedido está en'+ self.status.split('_').map(&:capitalize).join(' ')
    end
  end

  # Cambia estado del pedido a "Paquete recibido" y se reciben los lotes
  def receive_order(a_user)
    if provision_en_camino?
      if self.quantity_ord_supply_lots.where.not(sector_supply_lot: nil).exists?
        self.quantity_ord_supply_lots.each do |qosl|
          qosl.increment_lot_to(a_user.sector)
        end
        self.date_received = DateTime.now
        self.received_by = a_user
        self.provision_entregada!
      else
        raise ArgumentError, 'No hay insumos para recibir en el pedido'
      end # End check if sector supply exists
    else 
      raise ArgumentError, 'El pedido está en'+ self.status.split('_').map(&:capitalize).join(' ')
    end
  end

  # Cambia estado del pedido a "Paquete recibido" y se reciben los lotes
  def receive_remit(a_user)
    if self.recibo_auditoria?
      if self.quantity_ord_supply_lots.where.not(lot_code: nil).exists?
        self.quantity_ord_supply_lots.each do |qosl|
          qosl.increment_new_lot_to(a_user.sector)
        end
        self.date_received = DateTime.now
        self.received_by = a_user
        self.recibo_realizado!
      else
        raise ArgumentError, 'No hay insumos para recibir en el pedido'
      end # End check if sector supply exists
    else 
      raise ArgumentError, 'El pedido está en'+ self.status.split('_').map(&:capitalize).join(' ')
    end
  end

  def send_request_of(a_user)
    if self.solicitud_auditoria?
      self.sent_request_by = a_user
      self.solicitud_enviada!
    else
      raise ArgumentError, 'La solicitud no se encuentra en auditoría.'
    end
  end

  def return_status
    if proveedor_aceptado?
      self.proveedor_auditoria!
    elsif provision_en_camino?
      self.quantity_ord_supply_lots.each do |qosl|
        qosl.increment
      end
      self.proveedor_aceptado!
    elsif solicitud_enviada?
      self.solicitud_auditoria!
    else
      raise ArgumentError, 'No es posible retornar a un estado anterior'
    end
  end

  # Método para validar las cantidades a entregar de los lotes en stock
  def validate_quantity_lots
    @lots = self.quantity_ord_supply_lots.where.not(sector_supply_lot_id: nil) # Donde existe el lote
    if @lots.present?
      @sect_lots = @lots.select('sector_supply_lot_id, delivered_quantity').group_by(&:sector_supply_lot_id) # Agrupado por lote
      # Se itera el hash por cada lote sumando y verificando las cantidades.
      @sect_lots.each do |key, values|
        @sum_quantities = values.inject(0) { |sum, lot| sum += lot[:delivered_quantity]}
        @sector_lot = SectorSupplyLot.find(key)
        if @sector_lot.quantity < @sum_quantities
          raise ArgumentError, 'Stock insuficiente del lote '+@sector_lot.lot_code+' insumo: '+@sector_lot.supply_name
        end
      end
    else
      raise ArgumentError, 'No hay lotes asignados.'
    end   
  end

  def create_notification(of_user, action_type)
    OrderingSupplyMovement.create(user: of_user, ordering_supply: self, action: action_type, sector: of_user.sector)
    (self.applicant_sector.users.uniq - [of_user]).each do |user|
      Notification.create( actor: of_user, user: user, target: self, notify_type: self.order_type, action_type: action_type )
    end
    (self.provider_sector.users.uniq - [of_user]).each do |user|
      Notification.create( actor: of_user, user: user, target: self, notify_type: self.order_type, action_type: action_type )
    end
  end
end
