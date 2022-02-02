require 'rails_helper'

RSpec.describe InternalOrder, type: :model do
  
  it 'does not create' do
    order = InternalOrder.new
    expect(order.save).to be false
  end

  context 'on create' do
    before(:each) do
      @order = create(:order_1)
      @order_product = create(:order_product_1, order_id: @order.id)
    end

    it 'has status' do
      expect(@order).to be_solicitud_auditoria
    end

    it 'has order_type' do
      expect(@order).to be_solicitud
    end

    it 'has applicant_sector' do
      expect(@order.applicant_sector.name).to eq('Depósito')
    end

    it 'has provider_sector' do
      expect(@order.provider_sector.name).to eq('Farmacia')
    end

    it 'has observation' do 
      expect(@order.observation).to eq('observations')
    end

    it 'generates a remit_code' do
      expect(@order.remit_code).not_to be_nil
    end

    it 'has many products' do
      expect(@order.order_products.count).to be(1)
    end

    context 'on send requested order' do
      before(:each) do
        @sender = create(:simple_user)
        @order.send_request_by(@sender)
      end

      it 'has requested_date' do
        expect(@order.requested_date).not_to be_nil
      end

      it 'status change' do
        expect(@order).to be_solicitud_enviada
      end

      context 'on delivery order' do
        it 'without delivery_quantity' do
          @deliver = create(:user_1)
          @order.send_order_by(@deliver)
          expect(@order).to be_provision_en_camino
        end

        it 'might add new product to requested order' do
          @order_product = create(:order_product_2, order_id: @order.id)
          expect(@order.order_products.count).to be(2)
        end
      end

      context 'on nullify order' do
        it 'changes status' do
          @deliver = create(:user_1)
          @order.nullify_by(@deliver)
          expect(@order).to be_anulado
        end
      end

      context 'on receive order' do
        it 'changes status' do
          @deliver = create(:user_1)
          @order.send_order_by(@deliver)
          @order.receive_order_by(@sender)
          expect(@order).to be_provision_entregada
        end
      end
    end

    # it 'has date_received' do
    #   expect(@order.date_received).to eq('')
    # end

    # it 'has sent_date' do
      
    # end

  end
end
