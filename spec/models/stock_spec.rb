require 'rails_helper'

RSpec.describe Stock, type: :model do
  # Create stock
  it 'does not create' do
    stock = Stock.new
    expect(stock.save).to be false
  end

  it 'does create' do
    stock = build(:it_stock)
    expect(stock.save).to be true
  end

  context 'on created' do
    before(:each) do
      @stock = create(:it_stock)
    end

    it 'default quantity' do
      expect(@stock.quantity).to eq(0)
    end

    it 'default total_quantity' do
      expect(@stock.total_quantity).to eq(0)
    end

    it 'default reserved_quantity' do
      expect(@stock.reserved_quantity).to eq(0)
    end
  end
end
