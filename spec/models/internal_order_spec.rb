require 'rails_helper'

RSpec.describe InternalOrder, type: :model do
  
  it 'does not create' do
    order = InternalOrder.new
    expect(order.save).to be false
  end

  context 'on create' do

    before(:each) do
      @order = build(:order_1)
      @order_product = build(:order_product_1)
      @order.order_products << @order_product
      @order.save
    end

    it 'has status' do
      expect(@order.status).to eq('solicitud_auditoria')
    end

    it 'has order_type' do
      expect(@order.order_type).to eq('solicitud')
    end

    it 'has applicant_sector' do
      expect(@order.applicant_sector.name).to eq('Farmacia')
    end

    # it 'has provider_sector' do
      
    # end

    # it 'has date_received' do
      
    # end

    # it 'has observation' do 

    # end

    # it 'has requested_date' do

    # end

    # it 'has sent_date' do
      
    # end

    # it 'remit_code' do
      
    # end
  end
end
