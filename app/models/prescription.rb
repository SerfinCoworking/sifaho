class Prescription < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  # Estados
  enum status: { pendiente: 0, dispensada: 1, vencida: 2 }
  enum order_type: { receta: 0 }

  # Relaciones
  belongs_to :professional
  belongs_to :patient

  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots, dependent: :destroy
  has_many :supply_lots, -> { with_deleted }, :through => :sector_supply_lots
  has_many :supplies, -> { with_deleted }, :through => :quantity_ord_supply_lots
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :dispensed_by, class_name: 'User', optional: true

  # Validaciones
  validates_presence_of :patient, :professional, :prescribed_date, :expiry_date, :remit_code, :quantity_ord_supply_lots
  validates_associated :quantity_ord_supply_lots
  validates_uniqueness_of :remit_code, conditions: -> { with_deleted }

  # Atributos anidados
  accepts_nested_attributes_for :quantity_ord_supply_lots,
    :reject_if => :all_blank,
    :allow_destroy => true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_professional_and_patient,
      :search_supply_code,
      :search_supply_name,
      :sorted_by,
      :date_prescribed_since,
      :date_dispensed_since,
    ]
  )

  # SCOPES #--------------------------------------------------------------------

  pg_search_scope :search_professional_and_patient,
  :associated_against => { :professional => :fullname, patient: [:last_name, :first_name] },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply_code,
  :associated_against => { :supplies => :id, :sector_supply_lots => :code },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply_name,
  :associated_against => { :supplies => :name, :sector_supply_lots => :supply_name },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("prescriptions.created_at #{ direction }")
    when /^profesional_/
      # Ordenamiento por nombre de droga
      order("LOWER(professionals.first_name) #{ direction }").joins(:professional)
    when /^paciente_/
      # Ordenamiento por marca de medicamento
      order("LOWER(patients.first_name) #{ direction }").joins(:patient)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("prescriptions.status #{ direction }")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de insumo
      order("supplies.name #{ direction }").joins(:supplies)
    when /^recetada_/
      # Ordenamiento por la fecha de recepción
      order("prescriptions.prescribed_date #{ direction }")
    when /^recibida_/
      # Ordenamiento por la fecha de recepción
      order("prescriptions.date_received #{ direction }")
    when /^dispensada_/
      # Ordenamiento por la fecha de dispensación
      order("prescriptions.date_dispensed #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  # Prescripciones prescritas desde una fecha
  scope :date_prescribed_since, lambda { |reference_time|
    where('prescriptions.prescribed_date >= ?', reference_time)
  }

  # Prescripciones dispensadas desde una fecha
  scope :date_dispensed_since, lambda { |reference_time|
    where('prescriptions.date_dispensed >= ?', reference_time)
  }

  # Métodos públicos #----------------------------------------------------------

  def sum_to?(a_sector)
    if self.dispensada?
      return true unless self.dispensed_by.sector == a_sector
    end
  end

  def delivered_with_sector?(a_sector)
    if self.dispensada?
      return self.dispensed_by.sector == a_sector
    end
  end

  # Cambia estado a dispensado y descuenta la cantidad a los insumos
  def dispense
    if vencida?
      raise ArgumentError, "La prescripción está vencida"
    elsif dispensada?
      raise ArgumentError, "Ya se ha entregado esta prescripción"
    else
      if self.quantity_supply_lots.present?
        self.quantity_supply_lots.each do |qsls|
          qsls.decrement
        end
      else
        raise ArgumentError, 'No hay insumos en la prescripción'
      end
      self.date_dispensed = DateTime.now
      self.dispensada!
    end #End dispensada?
  end

  # Cambia estado a "dispensada" y descuenta la cantidad a los lotes de insumos
  def dispense_by_user_id(a_user_id)
    if self.pendiente?
      if self.quantity_ord_supply_lots.exists?
        if self.validate_quantity_lots
          self.quantity_ord_supply_lots.each do |qosl|
            qosl.decrement
          end
        end
      else
        raise ArgumentError, 'No hay insumos solicitados la prescripción'
      end # End check if quantity_ord_supply_lots exists
      self.dispensed_at = DateTime.now
      self.dispensed_by_id = a_user_id
      self.dispensada!
    else
      raise ArgumentError, 'La prescripción debe estar antes en pendiente.'
    end
  end

  def return_status
    if self.dispensada?
      self.quantity_ord_supply_lots.each do |qosl|
        qosl.increment
      end
      self.pendiente!
    else
      raise ArgumentError, 'No es posible retornar a un estado anterior'
    end
  end

  # Label del estado para vista.
  def status_label
    if self.dispensada?; return 'success';
    elsif self.pendiente?; return 'default';
    elsif self.vencida?; return 'danger'; end
  end

  # Métodos de clase #----------------------------------------------------------

  def self.current_day
    where("prescribed_date >= :today", { today: DateTime.now.beginning_of_day })
  end

  def self.current_month
    where("prescribed_date >= :month", { month: DateTime.now.beginning_of_month })
  end

  # Método para establecer las opciones del select sorted_by
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Doctor (a-z)', 'doctor_asc'],
      ['Paciente (a-z)', 'paciente_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recetada (desc)', 'recetada_desc'],
      ['Fecha recibida (desc)', 'recibida_desc'],
      ['Fecha dispensada (asc)', 'dispensada_asc'],
      ['Cantidad', 'cantidad_asc']
    ]
  end

  # Método para validar las cantidades a entregar de los lotes en stock
  def validate_quantity_lots
    @lots = self.quantity_ord_supply_lots.where.not(sector_supply_lot_id: nil) # Donde existe el lote
    if @lots.present?
      @sect_lots = @lots.select('sector_supply_lot_id, delivered_quantity').group_by(&:sector_supply_lot_id) # Agrupado por lote
      # Se itera el hash por cada lote sumando y se verifica que las cantidades a dispensar no superen las que hay en stock.
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
end
