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

  context 'create factories' do
    before(:each) do
      @product = create(:unidad_product)
      @laboratory = create(:abbott_laboratory)
      @provenance = create(:province_lot_provenance)
      lot = create(:lot,
                    product: @product,
                    expiry_date: Date.new(2022, 01, 25),
                    code: 'AAA-11',
                    laboratory: @laboratory,
                    provenance: @provenance)
      @stock = create(:it_stock_without_product, product: @product)
      @lot_stock = LotStock.new
      @lot_stock.lot = lot
      @lot_stock.stock = @stock
    end

    it 'update stock quantity after lot_stock increment' do
      expect(@stock.quantity).to eq(0)
      @lot_stock.increment(100)
      expect(@stock.quantity).to eq(100)
    end

    it 'update stock reserved_quantity after lot_stock increment it reserve' do
      expect(@stock.reserved_quantity).to eq(0)
      @lot_stock.increment(100)
      @lot_stock.reserve(10)
      expect(@stock.reserved_quantity).to eq(10)
    end

    it 'update stock total_quantity after a second lot_stock increments' do
      expect(@stock.total_quantity).to eq(0)
      @lot_stock.increment(100)
      expect(@stock.total_quantity).to eq(100)

      lot = create(:lot,
                   product: @product,
                   expiry_date: Date.new(2023, 01, 25),
                   code: 'AAA-12',
                   laboratory: @laboratory,
                   provenance: @provenance)
      lot_stock_nd = LotStock.new(lot: lot, stock: @stock)
      lot_stock_nd.increment(1500)
      expect(@stock.total_quantity).to eq(1600)
    end

    it 'total quantity it is a sum of quantity and reserved quantity' do
      expect(@stock.total_quantity).to eq(0)
      @lot_stock.increment(rand(500..1000))
      @lot_stock.reserve(rand(1..499))
      expect(@stock.total_quantity).to eq(@stock.quantity + @stock.reserved_quantity)
    end
  end
end
