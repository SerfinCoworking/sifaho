module FindLots
  extend ActiveSupport::Concern

  def find_lots
    self.set_order_product
    @selected_lot_stocks = @order_product.order_prod_lot_stocks.pluck(:lot_stock_id)
    @lot_stocks = LotStock.joins(:stock)
      .joins(:product)
      .where("stocks.sector_id = ?", current_user.sector.id)
      .where("products.id = ?", params[:product_id])
      .where("lot_stocks.quantity > ? OR lot_stocks.id IN (?)", 0, @selected_lot_stocks)
      .order("lots.expiry_date")
      
    respond_to do |format|
      format.json { render json: @lot_stocks.to_json(
        :include => { 
          :lot => {
            :only => [:code, :expiry_date, :status], 
            :include => {
              :laboratory => {:only => [:name]}
            } 
          }
        }), status: :ok }
    end
  end
  
end