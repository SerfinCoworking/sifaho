module OrderProductLotStock
  extend ActiveSupport::Concern

  # Relationship
  included do 
    belongs_to :lot_stock

    # Validations
    validates :quantity,
              numericality: {
                only_integer: true,
                less_than_or_equal_to: :lot_stock_quantity
              }

    validates :quantity,
              numericality: {
                only_integer: true,
                greater_than: 0
              }

    validates_presence_of :lot_stock_id

    # Callbacks
    before_create :reserve_quantity
    before_update :update_reserved_quantity
    before_destroy :return_reserved_quantity

    private

    def lot_stock_quantity
      lot_stock.quantity
    end

    # Quitamos lo reservado
    def return_reserved_quantity
      lot_stock.enable_reserved(reserved_quantity)
    end

    # Igualamos lo solocitado con lo reservado
    def reserve_quantity
      lot_stock.reserve(quantity)
      self.reserved_quantity = quantity
    end

    # Quitamos lo reservado
    # Reservamos el nuevo quantity
    # Actualizamos reserved_quantity con el nuevo quantity
    def update_reserved_quantity
      lot_stock.enable_reserved(reserved_quantity)
      lot_stock.reserve(quantity)
      self.reserved_quantity = quantity
    end
  end
end
