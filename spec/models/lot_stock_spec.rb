require 'rails_helper'

RSpec.describe LotStock, type: :model do
  it 'does not create' do
    lot_stock = LotStock.new
    expect(lot_stock.save).to be false
  end

  context 'create factories' do
    before(:each) do
      product = create(:unidad_product)
      lot = create(:province_lot_without_product, product: product)
      stock = create(:it_stock_without_product, product: product)
      @lot_stock = LotStock.new
      @lot_stock.lot = lot
      @lot_stock.stock = stock
    end

    it 'does create' do
      expect(@lot_stock.save!).to be true
    end

    # attribute
    it 'default quantity' do
      expect(@lot_stock.quantity).to eq(0)
    end

    it 'set quantity' do
      @lot_stock.quantity = 100
      expect(@lot_stock.quantity).to eq(100)
    end

    it 'default archived_quantity' do
      expect(@lot_stock.archived_quantity).to eq(0)
    end

    it 'set archived_quantity' do
      @lot_stock.archived_quantity = 5
      expect(@lot_stock.archived_quantity).to eq(5)
    end

    it 'default reserved_quantity' do
      expect(@lot_stock.reserved_quantity).to eq(0)
    end

    it 'set reserved_quantity' do
      @lot_stock.reserved_quantity = 16
      expect(@lot_stock.reserved_quantity).to eq(16)
    end
  end
  

  # # validation
  # it 'quantity greater than or eaul to 0' do
    
  # end
  
  # it 'reserved_quantity greater than or equal to 0' do
    
  # end

  # it 'stock cannot be blank' do
    
  # end
  
  # # delegate
  # it 'has refresh quantity of stock' do
    
  # end

  # it 'has product name and code' do
    
  # end

  # it 'has lot attributes and lot provenance' do
    
  # end
  
  # # method
  # it 'increments quantity' do
  # end
  
  # it 'decrements quantity' do
  # end
  
  # it 'increments archived quantity' do
  # end
  
  # it 'decrements archived quantity' do
  # end
  
  # it 'enabled reserved quantity' do
  # end
  
  # it 'reserve quantity' do
  # end
  
  # it 'total quantity' do
  # end

  # # relationship


  # # callback
  # it 'resfresh stock quantity after save' do
    
  # end
end
