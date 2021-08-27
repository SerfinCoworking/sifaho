class Establishments::ExternalOrders::ProductsController < ApplicationController
  before_action :set_external_order, only: [:new]

  def new
    puts "================================DEBUG"
    @external_order_product = ExternalOrderProduct.new(external_order_id: @external_order.id)
    # respond_to do |format|
    #   format.js
    # end
  end
  
  def create
    puts "<========================================= in create"
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
