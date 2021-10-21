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

    # Decrement each order prod lot stock of a product
    def decrement_reserved_quantity
      lot_stock.decrement_reserved(reserved_quantity)
      lot_stock.stock.create_stock_movement(order_product.order, lot_stock, quantity, false)
      update_column(:reserved_quantity, 0)
    end
    
    # Decrement each order prod lot stock of a product
    def validates_decrement_reserved_quantity
      # Lot stock reserved is less than required quantity, raise an error
      if (lot_stock.reserved_quantity < reserved_quantity)
        raise ArgumentError, "No hay stock reservado en el lote código #{lot_stock.lot.code} / producto #{product.code}."
      end
    end

    # Restore reserved quantity
    def return_reserved_quantity
      lot_stock.enable_reserved(reserved_quantity)
    end

    private

    def lot_stock_quantity
      lot_stock.quantity
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
