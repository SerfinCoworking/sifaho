class Establishments::ExternalOrders::ProductsController < ApplicationController
  before_action :set_external_order, only: [:new]

  def new
    @external_order_product = @external_order.order_products.build(external_order_id: @external_order.id)
    @form_id = DateTime.now.to_s(:number)
    # ExternalOrderProduct.new(id: DateTime.now.to_s(:number), external_order_id: @external_order.id)
  end

  def create
    puts "<========================================= in create"
    puts params
    flash.now[:success] = "Se agregó el producto correctamente."
  end

  def update
  end

  def destroy

  end

  private
  def set_external_order
    @external_order = ExternalOrder.find(params[:applicant_id])
  end

  def set_external_order_product
    @external_order_product = ExternalOrder.find(params[:id])
  end
end
