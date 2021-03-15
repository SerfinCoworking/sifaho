class InternalOrderTemplate < ApplicationRecord

  enum order_type: { solicitud: 0, provision: 1 }

  belongs_to :owner_sector, class_name: 'Sector'
  belongs_to :destination_sector, class_name: 'Sector'
  belongs_to :created_by, class_name: "User"
  has_many :internal_order_product_templates, dependent: :destroy
  has_many :products, through: :internal_order_product_templates

  # Deprecated: despues de correr la migracion
  has_many :internal_order_template_supplies, -> { order(rank: :asc) }, dependent: :destroy, inverse_of: :internal_order_template
  has_many :supplies, through: :internal_order_template_supplies

  validates_presence_of :name
  validates_associated :internal_order_product_templates

  accepts_nested_attributes_for :internal_order_product_templates,
    reject_if: ->(eopt){ eopt['product_id'].blank? },
    :allow_destroy => true

end
