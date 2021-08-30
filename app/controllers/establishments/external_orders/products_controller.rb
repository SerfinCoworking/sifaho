class Establishments::ExternalOrders::ProductsController < ApplicationController
  before_action :set_external_order, only: [:new, :show]
  before_action :set_external_order_product, only: [:show, :update]

  def new
    @external_order_product = @external_order.order_products.build
    @form_id = DateTime.now.to_s(:number)
  end
  
  def show
  end

  def create
    @external_order_product = ExternalOrderProduct.new(order_product_params)
    @external_order_product.save
    flash.now[:success] = "Se agregó el producto #{@external_order_product.product_name} correctamente."
  end

  def update
    @external_order_product.update(order_product_params)
    flash.now[:success] = "Se actualizó el producto #{@external_order_product.product_name} correctamente."
  end

  def destroy

  end

  private
  def set_external_order
    @external_order = ExternalOrder.find(params[:applicant_id])
  end

  def set_external_order_product
    @external_order_product = ExternalOrderProduct.find(params[:id])
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
