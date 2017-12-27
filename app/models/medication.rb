class Medication < ActiveRecord::Base
  attr_accessor :name

  validates :vademecum, presence: true
  validates :medication_brand, presence:true
  validates :expiry_date, presence: true
  validates :date_received, presence:true

  belongs_to :vademecum
  belongs_to :medication_brand

  has_many :quantity_medications
  has_many :prescriptions,
           :through => :quantity_medications,
           :source => :quantifiable,
           :source_type => 'Prescription'

  accepts_nested_attributes_for :medication_brand,
         :reject_if => :all_blank

  filterrific(
   default_filter_params: { sorted_by: 'created_at_desc' },
   available_filters: [
     :sorted_by,
     :search_query,
   ]
  )
 # define ActiveRecord scopes for
 # :search_query, :sorted_by

 scope :search_query, lambda { |query|
   # Searches the students table on the 'first_name' and 'last_name' columns.
   # Matches using LIKE, automatically appends '%' to each term.
   # LIKE is case INsensitive with MySQL, however it is case
   # sensitive with PostGreSQL. To make it work in both worlds,
   # we downcase everything.
   return nil  if query.blank?

   # condition query, parse into individual keywords
   terms = query.downcase.split(/\s+/)

   # replace "*" with "%" for wildcard searches,
   # append '%', remove duplicate '%'s
   terms = terms.map { |e|
     (e.gsub('*', '%') + '%').gsub(/%+/, '%')
   }
   # configure number of OR conditions for provision
   # of interpolation arguments. Adjust this if you
   # change the number of OR conditions.
   num_or_conds = 2
   where(
     terms.map { |term|
       "(LOWER(medications.vademecum.medication_name) LIKE ? OR LOWER(medications.medication_brand.name) LIKE ?)"
     }.join(' AND '),
     *terms.map { |e| [e] * num_or_conds }.flatten
   )
 }

 scope :sorted_by, lambda { |sort_option|
   # extract the sort direction from the param value.
   direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
   case sort_option.to_s
   when /^created_at_/
    # Ordenamiento por fecha de creación en la BD
     order("medications.created_at #{ direction }")
   when /^date_received_/
     # Ordenamiento por la fecha de recepción
     order("medications.date_received #{ direction }")
   when /^medication_name_/
     # Ordenamiento por nombre de droga
     order("LOWER(medications.vademecum.medication_name) #{ direction }")
   when /^brand_/
     # Ordenamiento por marca de medicamento
     order("LOWER(medications.medication_brand.name) #{ direction }")
   else
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
  # This method provides select options for the `sorted_by` filter select input.
  # It is called in the controller as part of `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Droga (a-z)', 'medication_name_asc'],
      ['Fecha recepción (la nueva primero)', 'date_received_desc'],
      ['Fecha de expiración (próxima a vencer primero)', 'expiry_date_asc'],
      ['Marca (a-z)', 'brand_asc']
    ]
  end
end
