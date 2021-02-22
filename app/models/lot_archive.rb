class LotArchive < ApplicationRecord
  belongs_to :user
  belongs_to :lot_stock

  enum status: { archivado: 0, retornado: 1 }

  validates :quantity, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }

  after_create :create_stock_movement_decrement

  def create_stock_movement_decrement
    self.lot_stock.stock.create_stock_movement(self, self.lot_stock, self.quantity, false)
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    self.lot_stock.stock.sector.name
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    self.observation
  end

  # Return the i18n model name
  def human_name
    self.class.model_name.human
  end
end
