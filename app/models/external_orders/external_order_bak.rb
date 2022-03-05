class ExternalOrderBak < ApplicationRecord
  acts_as_paranoid
  include PgSearch::Model

  enum order_type: { despacho: 0, solicitud_abastecimiento: 1, recibo: 2 }
  enum status: { solicitud_auditoria: 0, solicitud_enviada: 1, proveedor_auditoria: 2,
    proveedor_aceptado: 3, provision_en_camino: 4, provision_entregada: 5, recibo_auditoria: 6,
    recibo_realizado: 7, anulado: 8 }

  # Callbacks
  # before_validation :record_remit_code, on: :create
 
  # Relaciones
  belongs_to :applicant_sector, class_name: 'Sector', optional: true
  belongs_to :provider_sector, class_name: 'Sector', optional: true
  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :accepted_by, class_name: 'User', optional: true
  belongs_to :sent_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :sent_request_by, class_name: 'User', optional: true
  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :supplies, -> { with_deleted }, :through => :quantity_ord_supply_lots
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots
  has_many :movements, class_name: "ExternalOrderMovement", foreign_key: "external_order_id"
  has_many :comments, class_name: "ExternalOrderComment", foreign_key: "order_id"
  has_one :provider_establishment, :through => :provider_sector, :source => :establishment
  has_one :applicant_establishment, :through => :applicant_sector, :source => :establishment
  belongs_to :rejected_by, class_name: "User", optional: true

  accepts_nested_attributes_for :supplies, :sector_supply_lots
  accepts_nested_attributes_for :quantity_ord_supply_lots,
    reject_if: ->(qosl){ qosl['supply_id'].blank? },
    :allow_destroy => true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_code,
      :search_applicant,
      :search_provider,
      :with_order_type,
      :with_status,
      :requested_date_since,
      :requested_date_to,
      :date_received_since,
      :date_received_to,
      :sorted_by
    ]
  )

  pg_search_scope :search_code,
    against: :remit_code,
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_applicant,
    :associated_against => { :applicant_sector => :name, :applicant_establishment => :name },
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_provider,
    :associated_against => { :provider_sector => :name, :provider_establishment => :name },
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("external_orders.created_at #{ direction }")
    when /^responsable_/
      # Ordenamiento por nombre de responsable
      order("LOWER(responsable.username) #{ direction }").joins("INNER JOIN users as responsable ON responsable.id = external_orders.responsable_id")
    when /^sector_/
      # Ordenamiento por nombre de sector
      order("sectors.name #{ direction }").joins(:sector)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("external_orders.status #{ direction }")
    when /^tipo_/
      # Ordenamiento por nombre de estado
      order("external_orders.order_type #{ direction }")
    when /^ins_/
      # Ordenamiento por nombre de insumo solicitado
      order("quantity_ord_supply_lots.count #{ direction }")
    when /^solicitado_/
      # Ordenamiento por la fecha de recepción
      order("external_orders.requested_date #{ direction }") 
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("external_orders.date_received #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_since, lambda { |a_date|
    where('external_orders.date_received >= ?', a_date)
  }

  scope :date_received_to, lambda { |a_date|
    where('external_orders.date_received <= ?', a_date)
  }

  scope :requested_date_since, lambda { |a_date|
    where('external_orders.requested_date >= ?', a_date)
  }

  scope :requested_date_to, lambda { |a_date|
    where('external_orders.requested_date <= ?', a_date)
  }

  scope :with_status, lambda { |a_status|
    where('external_orders.status = ?', a_status)
  }

  scope :without_status, lambda { |a_status|
    where.not('external_orders.status = ?', a_status )
  }

  scope :without_order_type, lambda { |an_order_type|
    where.not('external_order_baks.order_type = ?', an_order_type )
  }

  scope :with_order_type, lambda { |a_order_type|
    where('external_orders.order_type = ?', a_order_type)
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

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Solicitud auditoria', 0, 'warning'],
      ['Solicitud enviada', 1, 'info'],
      ['Proveedor auditoria', 2, 'warning'],
      ['Proveedor aceptado', 3, 'primary'],
      ['Provisión en camino', 4, 'primary'],
      ['Provisión entregada', 5, 'success'],
      ['Recibo auditoria', 6, 'warning'],
      ['Recibo realizado', 7, 'success'],
      ['Anulado', 8, 'danger'],
    ]
  end

  public

  def self.provided_establishments_by(a_sector)
    @sector_ids = ExternalOrder.provider(a_sector).pluck(:applicant_sector_id).to_set
    return Establishment.joins(:sectors).where(sectors: { id: @sector_ids }).pluck(:id, :name).to_set
  end

  def self.applicant_establishment(a_establishment)
    @sector_ids = a_establishment.sectors.pluck(:id)
    applicant(@sector_ids)
  end

  def self.provider_establishment(a_establishment)
    @sector_ids = a_establishment.sectors.pluck(:id)
    provider(@sector_ids)
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

  def self.orders_to_sector(a_sector)
    @despachos = self.despacho.provider(a_sector).or(self.despacho.applicant(a_sector))
    @solicitud_abastecimientos = self.solicitud_abastecimiento.provider(a_sector).or(self.solicitud_abastecimiento.applicant(a_sector))
    @recibos = self.recibo.applicant(a_sector)
    @orders = @despachos.or(@solicitud_abastecimientos.or(@recibos))
  end

  def delivered_with_sector?(a_sector)
    if self.provision_en_camino? || self.provision_entregada?
      return self.applicant_sector == a_sector || self.provider_sector == a_sector
    elsif self.recibo_realizado?
      return self.applicant_sector == a_sector
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
      if self.validate_quantity_lots
        self.accepted_date = DateTime.now
        self.accepted_by = a_user
        self.proveedor_aceptado!
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
        self.sent_date = DateTime.now
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

  # Nullify the order
  def nullify_by(a_user)
    self.rejected_by = a_user
    self.anulado!
    self.create_notification(a_user, "Anuló")
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
    @qosl_with_ssl = self.quantity_ord_supply_lots.where.not(sector_supply_lot_id: nil) # Donde existe el lote
    @qosl_without_ssl = self.quantity_ord_supply_lots.where(sector_supply_lot_id: nil) # Donde existe el lote
    if @qosl_with_ssl.present?
      @sect_lots = @qosl_with_ssl.select('sector_supply_lot_id, delivered_quantity').group_by(&:sector_supply_lot_id) # Agrupado por lote
      # Se itera el hash por cada lote sumando y verificando las cantidades.
      @sect_lots.each do |key, values|
        @sum_quantities = values.inject(0) { |sum, lot| sum += lot[:delivered_quantity]}
        @sector_lot = SectorSupplyLot.find(key)
        if @sector_lot.quantity < @sum_quantities
          raise ArgumentError, 'Stock insuficiente del lote '+@sector_lot.lot_code+' insumo: '+@sector_lot.supply_name
        end
      end
    elsif @qosl_without_ssl.present?
      @qosl_without_ssl.each do |qosl|
        if qosl.delivered_quantity > 0
          raise ArgumentError, 'No hay lote asignado para el insumo cód '+ qosl.supply_id.to_s 
        end
      end
    else
      raise ArgumentError, 'No hay insumos en el pedido.'
    end 
  end

  def create_notification(of_user, action_type)
    ExternalOrderMovement.create(user: of_user, external_order: self, action: action_type, sector: of_user.sector)
    (self.applicant_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: self.order_type, action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
    (self.provider_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: self.order_type, action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  private

  def record_remit_code
    if self.despacho?
      self.remit_code = self.provider_sector.name[0..3].upcase+'des'+ExternalOrder.with_deleted.maximum(:id).to_i.next.to_s
    elsif self.solicitud_abastecimiento?
      self.remit_code = self.applicant_sector.name[0..3].upcase+'sla'+ExternalOrder.with_deleted.maximum(:id).to_i.next.to_s
    elsif self.recibo?
      self.remit_code= self.applicant_sector.name[0..3].upcase+'rec'+ExternalOrder.with_deleted.maximum(:id).to_i.next.to_s
    end
  end
end
