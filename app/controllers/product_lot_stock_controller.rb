class ProductLotStockController < ApplicationController

  before_action :find_order
  append_before_action :find_order_product, only: [ :find_lots, :update_lot_stock_selection ]

  def find_lots
    @selected_lot_stocks = @order_product.order_prod_lot_stocks.pluck(:lot_stock_id)
    @lot_stocks = LotStock.joins(:stock)
      .joins(:product)
      .where("stocks.sector_id = ?", current_user.sector.id)
      .where("products.id = ?", @order_product.product.id)
      .where("lot_stocks.quantity > ? OR lot_stocks.id IN (?)", 0, @selected_lot_stocks)
      .order("lots.expiry_date")

    # @order_product.order_prod_lot_stocks || 
    # @order_product.order_prod_lot_stocks.build
    respond_to do |format|
      # format.json { render json: @lot_stocks.to_json(
      #   :include => { 
      #     :lot => {
      #       :only => [:code, :expiry_date, :status], 
      #       :include => {
      #         :laboratory => {:only => [:name]}
      #       } 
      #     }
      #   }), status: :ok }
      format.js
    end
  end
  
  def update_lot_stock_selection
    respond_to do |format|
      @order_product.update!(lot_stock_params)
      begin
        format.js
      ensure
        format.html { render :find_lot_stock }
      end
    end
  end

  private
  def find_order
    @klass = params[:order_type].constantize
    @order = @klass.find(params[:order_id])
  end
  
  def find_order_product
    @order_product = @order.order_products.find(params[:order_product_id])
  end

  def lot_stock_params
    params.require(:order_products).permit(
      order_prod_lot_stocks_attributes: [
        :id,
        :lot_stock_id,
        :available_quantity,
        :_destroy
      ]
    )
  end

end