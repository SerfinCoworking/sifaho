class ReceiptProduct < ApplicationRecord
  belongs_to :receipt
  belongs_to :product
  belongs_to :laboratory
  belongs_to :lot_stock, optional: true
  belongs_to :lot, optional: true
  
  
  # Validaciones
  validates_presence_of :receipt, :product_id, :lot_code, :laboratory_id
  validates_presence_of :lot_stock_id, if: :is_recibido? 

  delegate :code, to: :product, prefix: true
  delegate :name, to: :product, prefix: true

  def increment_new_lot_to(a_sector)
    @lot = Lot.where(
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

    @lot_stock.increment(self.quantity)
    self.lot_stock_id = @lot_stock.id
    self.save!
  end

  def is_recibido? 
    self.receipt.recibido?
  end

end

