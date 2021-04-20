class InpatientPrescription < ApplicationRecord
  include PgSearch
  
  enum status: { 
    auditoria: 0,
    solicitud_enviada: 1,
    proveedor_auditoria: 2,
    proveedor_aceptado: 3,
    provision_en_camino: 4,
    provision_entregada: 5,
    anulado: 6 
  }

  # Relations
  belongs_to :patient
  belongs_to :professional
  belongs_to :bed
  belongs_to :prescribed_by, class_name: 'User'
  has_many :movements, class_name: 'InpatientPrescriptionMovement'
  has_many :order_products, dependent: :destroy, class_name: 'InpatientPrescriptionProduct', foreign_key: "order_id", inverse_of: 'inpatient_prescription'
  has_many :in_pre_prod_lot_stocks, through: :order_products, inverse_of: 'inpatient_prescription'
  has_many :lot_stocks, :through => :order_products
  has_many :lots, :through => :lot_stocks
  has_many :products, :through => :order_products  
  has_many :movements, class_name: "InpatientPrescriptionMovement"
  has_many :comments, class_name: "InpatientPrescriptionComment", foreign_key: "order_id", dependent: :destroy

  # Validaciones
  validates_associated :order_products
  validates :professional, presence: true
  validates :patient, presence: true
  validates :remit_code, presence: true, uniqueness: true
  validates :prescribed_by, presence: true
  validate :is_the_prescriptor?


  private 

  def is_the_prescriptor?
    self.professional_id == self.prescribed_by.professional_id 
  end
end
