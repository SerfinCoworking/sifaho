class Medication < ActiveRecord::Base
  attr_accessor :name

  validates :vademecum, presence: true
  validates :medication_brand, presence:true
  validates :expiry_date, presence: true
  validates :date_received, presence:true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
    ]
  )

  belongs_to :vademecum
  belongs_to :medication_brand

  has_many :quantity_medications
  has_many :prescriptions,
           :through => :quantity_medications,
           :source => :quantifiable,
           :source_type => 'Prescription'

  accepts_nested_attributes_for :medication_brand,
         :reject_if => :all_blank

 # define ActiveRecord scopes for
 # :search_query, :sorted_by

 scope :search_query, lambda { |query|
   #Se retorna nil si no hay texto en la query
   return nil  if query.blank?

   # Se pasa a minusculas para busqueda en postgresql
   # Luego se dividen las palabras en claves individuales
   terms = query.downcase.split(/\s+/)

   # Remplaza "*" con "%" para busquedas abiertas con LIKE
   # Agrega '%', remueve los '%' duplicados
   terms = terms.map { |e|
     (e.gsub('*', '%') + '%').gsub(/%+/, '%')
   }

   # Cantidad de condiciones.
   num_or_conds = 2
   where(
     terms.map { |term|
       "(LOWER(vademecums.medication_name) LIKE ? OR LOWER(medication_brands.name) LIKE ?)"
     }.join(' AND '),
     *terms.map { |e| [e] * num_or_conds }.flatten
   ).joins(:vademecum, :medication_brand)
 }

 scope :sorted_by, lambda { |sort_option|
   # extract the sort direction from the param value.
   direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
   case sort_option.to_s
   when /^created_at_/
    # Ordenamiento por fecha de creación en la BD
     order("medications.created_at #{ direction }")
   when /^droga_/
     # Ordenamiento por nombre de droga
     order("LOWER(vademecums.medication_name) #{ direction }").joins(:vademecum)
   when /^marca_/
     # Ordenamiento por marca de medicamento
     order("LOWER(medication_brands.name) #{ direction }").joins(:medication_brand)
   when /^fecha_recepcion_/
     # Ordenamiento por la fecha de recepción
     order("medications.date_received #{ direction }")
   when /^fecha_expiracion_/
     # Ordenamiento por la fecha de expiración
     order("medications.date_received #{ direction }")
   when /^cantidad_/
    # Ordenamiento por cantidad en stock
     order("medications.quantity #{ direction }")
   else
     # Si no existe la opcion de ordenamiento se levanta la excepcion
     raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
   end
 }
  def full_info
    if self.vademecum
      self.vademecum.medication_name<<" "<<self.medication_brand.name
    end
  end
  def name
    if self.vademecum
      self.vademecum.medication_name
    end
  end
  def brand
    if self.medication_brand
      self.medication_brand.name
    end
  end
  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Droga (a-z)', 'droga_asc'],
      ['Marca (a-z)', 'marca_asc'],
      ['Fecha recepción (la nueva primero)', 'fecha_recepcion_desc'],
      ['Fecha de expiración (próxima a vencer primero)', 'fecha_expiracion_asc'],
      ['Cantidad', 'cantidad_asc']
    ]
  end
end
