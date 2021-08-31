class Sectors::InternalOrders::ProductsController < ApplicationController
  before_action :set_internal_order, only: [:new]

  def new
    @internal_order_product = @internal_order.order_products.build
    @form_id = DateTime.now.to_s(:number)
  end

  def create
    @internal_order_product = InternalOrderProduct.new(order_product_params)
    
    respond_to do |format|
      if @internal_order_product.save
        flash.now[:success] = "Se agregó el producto #{@internal_order_product.product_name} correctamente."
      else
        flash.now[:alert] = 'Ha ocurrido un error al guardar el producto.'
        format.js {  }
      end
    end
  end

  def update
  end

  def destroy

  end

  private

  def set_internal_order
    @internal_order = InternalOrder.find(params[:applicant_id])
  end

  def set_internal_order_product
    @internal_order_product = InternalOrder.find(params[:id])
  end

  def order_product_params
    params.require(:order_product).permit(
      :order_id,
      :product_id,
      :request_quantity,
      :applicant_observation,
      :_destroy
    )
  end
end
