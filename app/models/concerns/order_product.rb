module OrderProduct
  extend ActiveSupport::Concern

  # Relationship
  included do 
    # Relationship
    belongs_to :product

    # Callbacks
    before_update :fill_delivery_quantity

    # Validations
    validates :request_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates_presence_of :product_id, :added_by_sector
    validate :uniqueness_product_in_the_order
    validate :order_prod_lot_stocks_any_without_stock

    accepts_nested_attributes_for :product,
                                  allow_destroy: true

    accepts_nested_attributes_for :order_prod_lot_stocks,
                                  reject_if: proc { |attributes| attributes['lot_stock_id'].blank? },
                                  allow_destroy: true
    # Delegations
    delegate :code, 
             :name, 
             :unity_name, 
             to: :product, 
             prefix: :product, 
             allow_nil: true
    private

    def fill_delivery_quantity
      self.delivery_quantity = order_prod_lot_stocks.sum(&:quantity)
    end

    # Increment lot stock quantity
    def increment_lot_stock_to(a_sector)

      self.order_prod_lot_stocks.each do |opls|

        @stock = Stock.where(
          sector_id: a_sector.id,
          product_id: self.product_id
        ).first_or_create

        @lot_stock = LotStock.where(
          lot_id: opls.lot_stock.lot.id,
          stock_id: @stock.id,
        ).first_or_create

        @lot_stock.increment(opls.quantity)
        
        @stock.create_stock_movement(order, @lot_stock, opls.quantity, true)
      end
    end

    # Incrementamos la cantidad de cada lot stock (orden)
  def increment_stock
    self.order_prod_lot_stocks.each do |opls|
      opls.lot_stock.increment(opls.quantity)
      opls.lot_stock.stock.create_stock_movement(order, opls.lot_stock, opls.quantity, true)
    end
  end

    # custom validations
    # Validacion: la cantidad no debe ser mayor o menor a la cantidad a entregar
  
    def lot_stock_sum_quantity
      total_quantity = 0
      self.order_prod_lot_stocks.each do |opls| 
        total_quantity += opls.quantity unless opls.marked_for_destruction?
      end
      if self.delivery_quantity.present? && self.delivery_quantity < total_quantity
        errors.add(:quantity_lot_stock_sum, "El total de productos seleccionados no debe superar #{self.delivery_quantity}")
      end
      
      if self.delivery_quantity.present? && self.delivery_quantity > total_quantity
        errors.add(:quantity_lot_stock_sum, "El total de productos seleccionados debe ser igual a #{self.delivery_quantity}")
      end
    end
    
    # Validacion: evitar duplicidad de productos en una misma orden
    def uniqueness_product_in_the_order
      (order.order_products.uniq - [self]).each do |order_product|
        if order_product.product_id == self.product_id
          errors.add(:uniqueness_product_in_the_order, "El producto código ya se encuentra en la orden")      
        end
      end
    end

    # Validacion: algun lote que se este seleccionando una cantidad superior a la persistente
    def order_prod_lot_stocks_any_without_stock
      any_insufficient_lot_stock = self.order_prod_lot_stocks.any? do |opls|
        opls.errors[:quantity].any?
      end
  
      if any_insufficient_lot_stock
        errors.add(:order_prod_lot_stocks_any_without_stock, "Revisar las cantidades seleccionadas")      
      end
    end

    # Validate: evitar el envio de una orden si no tiene stock para enviar
    def out_of_stock
      total_stock = order.provider_sector.stocks.where(product_id: self.product_id).sum(:quantity)
      if self.delivery_quantity.present? && total_stock < self.delivery_quantity
        errors.add(:out_of_stock, "Este producto no tiene el stock necesario para entregar")
      end
    end

    def get_order
      return order
    end

  end
end
