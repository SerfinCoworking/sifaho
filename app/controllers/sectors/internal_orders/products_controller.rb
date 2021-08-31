class Sectors::InternalOrders::ProductsController < ApplicationController
  before_action :set_order, only: %i[new]
  before_action :set_order_product, only: %i[update destroy]

  def new
    @order_product = @order.order_products.build
    @form_id = DateTime.now.to_s(:number)
  end

  def create
    @order_product = InternalOrderProduct.new(order_product_params)
    @form_id = params[:form_id]

    respond_to do |format|
      if @order_product.save
        flash.now[:success] = "Se agregó el producto #{@order_product.product_name} correctamente."
      else
        flash.now[:alert] = 'Ha ocurrido un error al guardar el producto.'
      end
      format.js { render 'shared/orders/products/create' }
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
    flash.now[:success] = "Se eliminó el producto #{@order_product.product_name} correctamente."
    @order_product_id = @order_product.id
    @order_product.destroy
    respond_to do |format|
      format.js { render 'shared/orders/products/destroy' }
    end
  end

  private

  def set_order
    @order = InternalOrder.find(params[:applicant_id])
  end

  def set_order_product
    @order_product = InternalOrderProduct.find(params[:id])
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
