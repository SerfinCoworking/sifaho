class Medication < ApplicationRecord
  attr_accessor :name

  validates :vademecum, presence: true
  validates :expiry_date, presence: true
  validates :date_received, presence:true

  belongs_to :vademecum
  belongs_to :medication_brand

  has_many :quantity_medications
  has_many :prescriptions,
           :through => :quantity_medications,
           :source => :quantifiable,
           :source_type => 'Prescription'

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
end
