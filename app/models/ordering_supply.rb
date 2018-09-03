class OrderingSupply < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  enum applicant_status: { auditoria: 0, aceptado: 1, en_camino: 2, entregado: 3, anulado: 4 }, _prefix: :applicant
  enum provider_status: { auditoria: 0, aceptado: 1, en_camino: 2, entregado: 3, anulado: 4 }, _prefix: :provider

  # Relaciones
  belongs_to :applicant_sector, class_name: 'Sector'
  belongs_to :provider_sector, class_name: 'Sector'
  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :accepted_by, class_name: 'User', optional: true
  belongs_to :sent_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true
  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :supplies, -> { with_deleted }, :through => :quantity_ord_supply_lots
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots

  # Validaciones
  validates_presence_of :applicant_sector
  validates_presence_of :provider_sector
  validates_presence_of :quantity_ord_supply_lots
  validates_associated :quantity_ord_supply_lots
  validates_associated :supplies
  validates_associated :sector_supply_lots

  accepts_nested_attributes_for :supplies
  accepts_nested_attributes_for :sector_supply_lots
  accepts_nested_attributes_for :quantity_ord_supply_lots,
          :reject_if => :all_blank,
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
  :associated_against => { supply_lots: [:supply_name, :code] },
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
      order("sectors.sector_name #{ direction }").joins(:sector)
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

  def deliver
    if entregado?
      raise ArgumentError, "Ya se ha entregado este pedido"
    else
      if self.quantity_supply_lots.present?
        self.quantity_supply_lots.each do |qsls|
          qsls.decrement
        end
      else
        raise ArgumentError, 'No hay lotes en el pedido'
      end
      self.date_delivered = DateTime.now
      self.entregado!
    end #End entregado?
  end

  # Label del estado para vista.
  def provider_status_label
    if self.provider_auditoria?; return 'default'
    elsif self.provider_aceptado?; return 'primary'
    elsif self.provider_en_camino?; return 'info'
    elsif self.provider_entregado?; return 'success'
    elsif self.provider_anulado?; return 'danger'
    end
  end

  # Porcentaje de la barra de estado
  def percent_status
    if self.provider_auditoria?; return 5
    elsif self.provider_aceptado?; return 34
    elsif self.provider_en_camino?; return 71
    elsif self.provider_entregado?; return 100
    elsif self.provider_anulado?; return 100
    end
  end

  def audited_by_info
    if self.provider_auditoria?
      return 'Auditado por '+self.audited_by.full_name
    else
      return 'Sin auditar'
    end
  end
  def accepted_by_info
    if self.provider_aceptado?
      return 'Aceptado por '+self.accepted_by.full_name
    else
      return 'Sin aceptar'
    end
  end
  def sent_by_info
    if self.provider_en_camino?
      return 'En camino por '+self.sent_by.full_name
    else
      return 'Sin enviar'
    end
  end
  def received_by_info
    if self.provider_entregado?
      return 'Recibido por '+self.received_by.full_name
    else
      return 'Sin entregar'
    end
  end

  # Cambia estado a "en camino" y descuenta la cantidad a los insumos
  def send_order
    if provider_anulado?
      raise ArgumentError, "El pedido está anulado"
    elsif provider_en_camino?
      raise ArgumentError, "El pedido ya se encuentra en camino"
    else
      if self.quantity_ord_supply_lots.exists?
        if self.quantity_ord_supply_lots.where.not(sector_supply_lot: nil).exists?
          self.quantity_ord_supply_lots.each do |qosl|
            qosl.decrement
          end
        else
          raise ArgumentError, 'No hay insumos a entregar en el pedido'
        end # End chack if sector supply exists
      else
        raise ArgumentError, 'No hay insumos solicitados en el pedido'
      end # End check if quantity_ord_supply_lots exists
      self.sent_date = DateTime.now
      self.provider_en_camino!
    end # End anulado?
  end

  # Cambia estado del pedido a "Aceptado" y se verifica que hayan lotes
  def accept_order
    if provider_anulado? || applicant_anulado?
      raise ArgumentError, "El pedido está anulado"
    elsif provider_aceptado?
      raise ArgumentError, "El pedido ya ha sido aceptado"
    elsif provider_en_camino?
      raise ArgumentError, "El pedido ya se encuentra en camino"
    else
      if self.quantity_ord_supply_lots.present?
        self.accepted_date = DateTime.now
        self.provider_aceptado!
      else
        raise ArgumentError, 'No hay insumos solicitados en el pedido'
      end
    end #End anulado?
  end

  def return_provider_status
    if provider_auditoria?
      raise ArgumentError, "No hay más estados a retornar"
    elsif provider_aceptado?
      self.provider_auditoria!
    elsif provider_en_camino?
      self.quantity_ord_supply_lots.each do |qosl|
        qosl.increment
      end
      self.provider_aceptado!
    elsif provider_entregado?
      raise ArgumentError, "Ya se ha entregado el pedido"
    end
  end

  private

  def assign_sector
    self.sector = self.responsable.sector
  end

end
