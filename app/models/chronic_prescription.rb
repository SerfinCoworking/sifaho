class ChronicPrescription < ApplicationRecord

  include PgSearch

  enum status: { pendiente: 0, dispensada: 1, dispensada_parcial: 2, vencida: 3 }

  # Relaciones
  belongs_to :professional
  belongs_to :patient
  belongs_to :provider_sector, class_name: 'Sector', optional: true
  belongs_to :establishment

  has_many :chronic_dispensations, dependent: :destroy, inverse_of: 'chronic_prescription'
  has_many :chronic_prescription_products, :through => :chronic_dispensations
  has_many :original_chronic_prescription_products, dependent: :destroy, inverse_of: 'chronic_prescription'
  
  # has_many :lot_stocks, :through => :chronic_prescription_products, dependent: :destroy
  # has_many :lots, :through => :lot_stocks

  has_many :products, :through => :chronic_prescription_products
  has_many :movements, class_name: "ChronicPrescriptionMovement"

  # Validaciones
  validates_presence_of :patient, :professional, :date_prescribed, :remit_code
  validates :original_chronic_prescription_products, :presence => {:message => "Debe agregar almenos 1 insumo"}
  validates_associated :original_chronic_prescription_products
  validates_uniqueness_of :remit_code

  # Atributos anidados
  accepts_nested_attributes_for :original_chronic_prescription_products,
  :allow_destroy => true
  
  accepts_nested_attributes_for :chronic_dispensations,
  :allow_destroy => true
  
  accepts_nested_attributes_for :chronic_prescription_products,
  :allow_destroy => true

  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient
  delegate :enrollment, :fullname, to: :professional, prefix: :professional

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_by_professional,
      :search_by_patient,
      :search_by_product,
      :sorted_by,
      :date_prescribed_since,
    ]
  )

  pg_search_scope :search_by_professional,
  :associated_against => { professional: [ :last_name, :first_name ] },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_by_patient,
  :associated_against => { patient: [ :last_name, :first_name, :dni ] },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_by_product,
  :associated_against => { products: [ :id, :name ] },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("chronic_prescriptions.created_at #{ direction }")
    when /^profesional_/
      # Ordenamiento por nombre de droga
      order("LOWER(professionals.first_name) #{ direction }").joins(:professional)
    when /^paciente_/
      # Ordenamiento por marca de medicamento
      order("LOWER(patients.first_name) #{ direction }").joins(:patient)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("chronic_prescriptions.status #{ direction }")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de insumo
      order("supplies.name #{ direction }").joins(:supplies)
    when /^recetada_/
      # Ordenamiento por la fecha de recepción
      order("chronic_prescriptions.prescribed_date #{ direction }")
    when /^recibida_/
      # Ordenamiento por la fecha de recepción
      order("chronic_prescriptions.date_received #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
  
  # Prescripciones prescritas desde una fecha
  scope :date_prescribed_since, lambda { |reference_time|
    where('chronic_prescriptions.prescribed_date >= ?', reference_time)
  }

  scope :with_establishment, lambda { |a_establishment|
    where('chronic_prescriptions.establishment_id = ?', a_establishment)
  }

  # def is_dispensing?
  #   return self.dispensada_parcial?
  # end

  

  def create_notification(of_user, action_type)
    ChronicPrescriptionMovement.create(user: of_user, chronic_prescription: self, action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: "crónica", action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  # Actualiza el estado de: ChronicPrescription a "dispensada" y si se completo el ciclo de la receta
  # se actualiza el estado de la receta a "dispensada"
  def dispense_by
    # si completamos las dispensaciones de cada producto, entonces actualizamos el estado de la receta a "dispensada"
    if self.original_chronic_prescription_products.sum(:total_request_quantity) <= self.original_chronic_prescription_products.sum(:total_delivered_quantity)
      self.dispensada!
    end
  end
end
