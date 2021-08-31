class Sectors::InternalOrders::ProductsController < ApplicationController
  before_action :set_order, only: %i[new show create update]
  before_action :set_order_product, only: %i[show update destroy]

  def new
    @order_product = @order.order_products.build
    @form_id = (Time.now.to_f * 1000).to_i
    respond_to do |format|
      format.js { render 'shared/orders/products/new' }
    end
  end

  def show
    @form_id = @order_product.id
    respond_to do |format|
      format.js { render 'shared/orders/products/show' }
    end
  end

  def create
    @order_product = InternalOrderProduct.new(order_product_params)
    @form_id = params[:form_id]

    respond_to do |format|
      if @order_product.save
        flash.now[:success] = "Se agregó el producto #{@order_product.product_name} correctamente."
        format.js { render 'shared/orders/products/show' }
      else
        flash.now[:alert] = 'Ha ocurrido un error al guardar el producto.'
        format.js { render 'shared/orders/products/new' }
      end
    end
  end

  def update
    respond_to do |format|
      @form_id = @order_product.id
      if @order_product.update(order_product_params)
        flash.now[:success] = "El producto #{@order_product.product_name} se ha actualizado correctamente."
        format.js { render 'shared/orders/products/show' }
      else
        flash.now[:alert] = 'Ha ocurrido un error al actualizar el producto.'
        format.js { render 'shared/orders/products/new' }
      end
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
