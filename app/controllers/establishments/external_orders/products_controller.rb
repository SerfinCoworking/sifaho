class Establishments::ExternalOrders::ProductsController < ApplicationController
  before_action :set_order, only: %i[new show create]
  before_action :set_order_product, only: %i[show update]

  def new
    @external_order_product = @external_order.order_products.build
    @form_id = DateTime.now.to_s(:number)
  end

  def show
  end

  def create
    @order_product = ExternalOrderProduct.new(order_product_params)
    @form_id = params[:form_id]

    respond_to do |format|
      if @order_product.save
        flash.now[:success] = "Se agregó el producto #{@order_product.product_name} correctamente."
      else
        flash.now[:alert] = 'Ha ocurrido un error al guardar el producto.'
        format.js { render 'shared/orders/products/create' }
      end
    end
  end

  def update
    respond_to do |format|
      if @order_product.update(order_product_params)
        flash.now[:success] = "El producto #{@order_product.product_name} se ha actualizado correctamente."
      else
        flash.now[:alert] = 'Ha ocurrido un error al actualizar el producto.'
      end
      format.js { render 'shared/orders/products/update' }
    end
  end

  def destroy
    product_name = @external_order_product.product_name
    @order_product_id = @external_order_product.id
    @external_order_product.destroy
    flash.now[:success] = "Se eliminó el producto #{product_name} correctamente."
  end

  private

  def set_order
    @order = ExternalOrder.find(params[:applicant_id])
  end

  def set_order_product
    @order_product = ExternalOrderProduct.find(params[:id])
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
