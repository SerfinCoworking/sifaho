class LotArchive < ApplicationRecord
  belongs_to :user
  belongs_to :lot_stock

  enum status: { archivado: 0, retornado: 1 }

  validates :quantity, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }

  after_create :create_stock_movement_decrement

  def create_stock_movement_decrement
    self.lot_stock.stock.create_stock_movement(self, self.lot_stock, self.quantity, false)
  end
end
