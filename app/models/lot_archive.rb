class LotArchive < ApplicationRecord
  belongs_to :user
  belongs_to :returned_by, class_name: 'User', optional: true
  belongs_to :lot_stock

  enum status: { archivado: 0, retornado: 1 }

  validates :quantity, 
    presence: true, 
    numericality: { only_integer: true, greater_than: 0}
  validates_presence_of :observation

  after_create :decrement_lot_stock

  def decrement_lot_stock
    self.lot_stock.increment_archived(self.quantity)
    self.lot_stock.stock.create_stock_movement(self, self.lot_stock, self.quantity, false)
  end
  
  def return_by(a_user)
    self.returned_by = a_user
    self.lot_stock.decrement_archived(self.quantity)
    self.retornado!
    self.lot_stock.stock.create_stock_movement(self, self.lot_stock, self.quantity, true)
  end

  def lot_stock_quantity
    return self.lot_stock.quantity
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    self.lot_stock.stock.sector.name+" "+self.lot_stock.stock.sector.establishment.short_name
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
