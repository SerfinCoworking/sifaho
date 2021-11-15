require 'rails_helper'

RSpec.describe LotStock, type: :model do
  it 'does not create' do
    lot_stock = LotStock.new
    expect(lot_stock.save).to be false
  end

  it 'does create' do
    
  end

  # attribute
  it 'quantity' do
    lot_stock = build(:lot_stock, quantity: 100)
    expect(lot_stock.quantity).to eq(100)
  end
  
  it 'archived_quantity' do
    
  end
  
  it 'reserved_quantity' do
    
  end

  # validation
  it 'quantity greater than or eaul to 0' do
    
  end
  
  it 'reserved_quantity greater than or equal to 0' do
    
  end

  it 'stock cannot be blank' do
    
  end
  
  # delegate
  it 'has refresh quantity of stock' do
    
  end

  it 'has product name and code' do
    
  end

  it 'has lot attributes and lot provenance' do
    
  end
  
  # method
  it 'increments quantity' do
  end
  
  it 'decrements quantity' do
  end
  
  it 'increments archived quantity' do
  end
  
  it 'decrements archived quantity' do
  end
  
  it 'enabled reserved quantity' do
  end
  
  it 'reserve quantity' do
  end
  
  it 'total quantity' do
  end

  # relationship


  # callback
  it 'resfresh stock quantity after save' do
    
  end
end
