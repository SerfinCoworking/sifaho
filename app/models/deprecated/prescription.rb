class Prescription < ApplicationRecord
  acts_as_paranoid
  include PgSearch::Model

  # Estados
  enum status: { pendiente: 0, dispensada: 1, dispensada_parcial: 2, vencida: 3 }
  enum order_type: { ambulatoria: 0, cronica: 1 }

  # Relaciones
  belongs_to :professional
  belongs_to :patient
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :dispensed_by, class_name: 'User', optional: true
  belongs_to :provider_sector, class_name: 'Sector', optional: true
  belongs_to :establishment

  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots, dependent: :destroy
  has_many :supply_lots, -> { with_deleted }, :through => :sector_supply_lots
  has_many :supplies, -> { with_deleted }, :through => :quantity_ord_supply_lots
  has_many :movements, class_name: "PrescriptionMovement"
  has_many :cronic_dispensations, :through => :quantity_ord_supply_lots

  # Validaciones
  validates_presence_of :patient, :professional, :prescribed_date, :remit_code
  validates :quantity_ord_supply_lots, :presence => {:message => "Debe agregar almenos 1 insumo"}
  validates_associated :quantity_ord_supply_lots
  validates_uniqueness_of :remit_code, conditions: -> { with_deleted }
  # Atributos anidados
  accepts_nested_attributes_for :quantity_ord_supply_lots,
    :reject_if => :all_blank,
    :allow_destroy => true

  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient
  delegate :enrollment, :fullname, to: :professional, prefix: :professional

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_by_professional,
      :search_by_patient,
      :search_by_supply,
      :sorted_by,
      :with_order_type,
      :date_prescribed_since,
      :date_dispensed_since,
    ]
  )

  # SCOPES #--------------------------------------------------------------------

  pg_search_scope :search_by_professional,
  :associated_against => { professional: [ :last_name, :first_name ] },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_by_patient,
  :associated_against => { patient: [ :last_name, :first_name, :dni ] },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_by_supply,
  :associated_against => { supplies: [ :id, :name ] },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
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

  scope :with_order_type, lambda { |a_order_type|
    where('prescriptions.order_type = ?', a_order_type)
  }

  scope :for_statuses, ->(values) do
    return all if values.blank?

    where(status: statuses.values_at(*Array(values)))
  end

  scope :with_establishment, lambda { |a_establishment|
    where('prescriptions.establishment_id = ?', a_establishment)
  }

  # Métodos públicos #----------------------------------------------------------
  def sum_to?(a_sector)
    if self.dispensada?
      return true unless self.provider_sector == a_sector
    end
  end

  def delivered_with_sector?(a_sector)
    if self.dispensada? || self.dispensada_parcial?
      return self.provider_sector == a_sector
    end
  end

  def professional_fullname
    self.professional.full_name
  end

  # Cambia estado a "dispensada" y descuenta la cantidad a los lotes de insumos
  def dispense_by(a_user_id)
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

  # Cambia estado a "dispensada" y descuenta la cantidad a los lotes de insumos
  def dispense_cronic_by(a_user)
    if self.pendiente? || self.dispensada_parcial?
      if self.times_dispensed < self.times_dispensation
        if self.quantity_ord_supply_lots.sin_entregar.exists?
          if self.validate_undelivered_quantity_lots(a_user.sector)
            cp = CronicDispensation.create(prescription: self)
            self.quantity_ord_supply_lots.sin_entregar.each do |qosl|
              qosl.decrement_to_cronic(cp)
            end
          end
        else
          raise ArgumentError, 'No hay insumos sin entregar en la prescripción'
        end # End check if quantity_ord_supply_lots exists
        self.times_dispensed += 1
        if self.times_dispensed == self.times_dispensation; self.dispensada!;else; self.dispensada_parcial!; end
        self.dispensed_at = DateTime.now
        self.dispensed_by = a_user
        self.save
      else
        raise ArgumentError, 'La receta ya se dispensó '+self.times_dispensed.to_s+' veces'
      end
    else
      raise ArgumentError, 'La prescripción debe está '+self.status
    end
  end

  # Return the last cronic dispensation
  def return_cronic_dispensation
    if self.dispensada_parcial? || self.dispensada?
      # Iterate through the supplies of the last dispensation
      self.cronic_dispensations.newest_first.first.quantity_ord_supply_lots.each do |qosl|
        qosl.increment # Return delivered quantity to stock
      end
      self.cronic_dispensations.newest_first.first.destroy # Destroy the last dispensation
      self.times_dispensed -= 1 # Rest one dispensation to counter
      self.dispensada_parcial!
    elsif self.dispensada_parcial? && self.times_dispensed == 1
      self.auditoria!
    else
      raise ArgumentError, 'No es posible retornar a un estado anterior'
    end
  end

  def return_ambulatory_dispensation
    if self.dispensada?
      self.quantity_ord_supply_lots.each do |qosl|
        qosl.increment
        qosl.sin_entregar!
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

  def sent_date
    self.dispensed_at
  end

  # Métodos de clase #----------------------------------------------------------
  scope :with_patient_id, lambda { |an_id|
    where(patient_id: [*an_id])
  }

  def self.current_day
    where("prescribed_date >= :today", { today: DateTime.now.beginning_of_day })
  end

  def self.last_week
    where("prescribed_date >= :last_week", { last_week: 1.weeks.ago.midnight })
  end

  def self.current_year
    where("prescribed_date >= :year", { year: DateTime.now.beginning_of_year })
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

  def validate_undelivered_quantity_lots(sector)
    @lots = self.quantity_ord_supply_lots.sin_entregar.where.not(sector_supply_lot_id: nil) # Donde existe el lote
    if @lots.present?
      @sect_lots = @lots.select('sector_supply_lot_id, delivered_quantity').group_by(&:sector_supply_lot_id) # Agrupado por lote
      # Se itera el hash por cada lote sumando y se verifica que las cantidades a dispensar no superen las que hay en stock.
      @sect_lots.each do |key, values|
        @sum_quantities = values.inject(0) { |sum, lot| sum += lot[:delivered_quantity]}
        @sector_lot = SectorSupplyLot.find(key)
        if @sector_lot.sector != sector
          raise ArgumentError, 'El lote '+@sector_lot.lot_code+' no pertenece a tu sector.'
        end
        if @sector_lot.quantity < @sum_quantities
          raise ArgumentError, 'Stock insuficiente del lote '+@sector_lot.lot_code+' insumo: '+@sector_lot.supply_name
        end
      end
    else
      raise ArgumentError, 'No hay lotes asignados.'
    end
  end

  def create_notification(of_user, action_type)
    PrescriptionMovement.create(user: of_user, prescription: self, action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: self.order_type, action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end
end
