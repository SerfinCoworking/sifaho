class ChronicDispensation < ApplicationRecord
  belongs_to :chronic_prescription, inverse_of: 'chronic_dispensations'
  has_many :dispensation_types, inverse_of: 'chronic_dispensation'

  enum status: { pendiente: 0, dispensada: 1}

  accepts_nested_attributes_for :dispensation_types,
  :allow_destroy => true

  after_create :decrement_stock, :dispense_prescription
  
  def decrement_stock
    self.dispensation_types.each do |dp|
       dp.chronic_prescription_products.each do |cpp|
        cpp.decrement_stock
      end
    end
  end
  
  # Incremnta la cantidad total dispensada:
  # Sumar 1 dosis o Sumar la cantidad segun corresponda [dispensation_type]
  def dispense_prescription
    
    self.chronic_prescription.original_chronic_prescription_products.each do |ocpp|
      dispensation_type = self.dispensation_types.where(original_chronic_prescription_product_id: ocpp.id).first

      # is_original_present = self.chronic_prescription_products.where(original_chronic_prescription_product_id: ocpp.id).first
      if dispensation_type.present?

        ocpp.total_delivered_quantity += dispensation_type.quantity
      end
      ocpp.save!
    end

    if self.chronic_prescription.pendiente?
      self.chronic_prescription.dispensada_parcial!
    end
    
    self.chronic_prescription.dispense_by
  end

  def return_dispensation
    # primero actualizamos los totales de la dosis de cada producto original recetado
    self.chronic_prescription.original_chronic_prescription_products.each do |ocpp|
      self.dispensation_types.each do |dp|
        # Retornamos la cantidad 
        is_original_present = dp.chronic_prescription_products.where(original_chronic_prescription_product_id: ocpp.id).first
        if is_original_present.present?
          ocpp.total_delivered_quantity -= dp.quantity
        end
      end
      ocpp.save!
    end
    
    self.dispensation_types.each do |dt| 
      dt.chronic_prescription_products.each do | cpp |
        cpp.increment_stock
      end
    end
  end

end