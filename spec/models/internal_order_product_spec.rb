require 'rails_helper'

RSpec.describe InternalOrderProduct, type: :model do
  context 'order_products' do

    before(:each) do
      @order = create(:order_1)
      @order_product = create(:order_product_1, order_id: @order.id)
    end

    it 'has a selected product' do
      expect(@order_product.product.code).to eq('1717')
    end

    it 'requested product has a requested_quantity' do
      expect(@order_product.request_quantity).to eq(10)
    end

    it 'requested product has a delivery_quantity on 0' do
      expect(@order_product.delivery_quantity).to eq(0)
    end

    it 'order status isn t proveedor_auditoria' do
      expect(@order_product).not_to be_is_proveedor_auditoria
    end

    it 'order status isn t provision_en_camino' do
      expect(@order_product).not_to be_is_provision_en_camino
    end

    it 'order type isn t provision' do
      expect(@order_product).not_to be_is_provision
    end
  end
end
