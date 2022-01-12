class ReceiptProduct < ApplicationRecord
  default_scope { joins(:product).order('products.name') }

  # Relationships
  belongs_to :receipt
  belongs_to :product
  belongs_to :laboratory, optional: true
  belongs_to :lot_stock, optional: true
  belongs_to :lot, optional: true
  belongs_to :provenance, class_name: 'LotProvenance'

  # Validations
  validates_presence_of :receipt, :product_id, :lot_code, :laboratory_id
  validates_presence_of :lot_stock_id, if: :is_recibido?
  validates :provenance_id, presence: true

  # Delegations
  delegate :code, :name, :unity_name, to: :product, prefix: true
  delegate :destiny_name, :origin_name, :status, to: :receipt
  delegate :name, to: :provenance, prefix: true
  delegate :name, to: :laboratory, prefix: true, allow_nil: true

  def increment_new_lot_to(a_sector)
    @lot = Lot.where(
      provenance_id: self.provenance_id,
      product_id: self.product_id,
      code: self.lot_code,
      laboratory_id: self.laboratory_id,
      expiry_date: self.expiry_date
    ).first_or_create

    @stock = Stock.where(
      sector_id: a_sector.id,
      product_id: self.product_id
    ).first_or_create

    @lot_stock = LotStock.where(
      lot_id: @lot.id,
      stock_id: @stock.id,
    ).first_or_create

    @lot_stock.increment(quantity, receipt)
    self.lot_stock_id = @lot_stock.id
    self.save!
  end

  def is_recibido? 
    self.receipt.recibido?
  end

  def order_human_name
    self.receipt.class.model_name.human
  end

  def is_destiny?(a_sector)
    return self.receipt.applicant_sector == a_sector
  end

  def order
    self.receipt
  end
end
