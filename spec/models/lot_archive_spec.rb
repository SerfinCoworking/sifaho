
require 'rails_helper'

RSpec.describe LotArchive, type: :model do
  it 'does not create' do
    lot_archive = LotArchive.new
    expect(lot_archive.save).to be false
  end

  context 'build lot_archive relations' do
    before(:each) do
      product = create(:unidad_product)
      lot = create(:province_lot_without_product, product: product)
      stock = create(:it_stock_without_product, product: product)
      @lot_stock = LotStock.new
      @lot_stock.lot = lot
      @lot_stock.stock = stock
      @user = create(:simple_user)
      @lot_stock.increment(1500)
      @lot_archive = LotArchive.new(quantity: 10, observation: 'Prueba de observación')
      @lot_archive.lot_stock = @lot_stock
      @lot_archive.user = @user
    end

    it 'does create' do
      expect(@lot_archive.save!).to be true
    end

    it 'has "archivado" as a default status' do
      expect(@lot_stock.quantity).to eq(1500)
      @lot_archive.quantity = 100
      @lot_archive.save
      expect(@lot_archive.status).to eq('archivado')
    end

    it 'after create decrement lot stock quantity' do
      expect(@lot_stock.quantity).to eq(1500)
      @lot_archive.quantity = 100
      @lot_archive.save
      expect(@lot_stock.quantity).to eq(1400)
    end

    it 'after create increment lot stock archive quantity' do
      expect(@lot_stock.quantity).to eq(1500)
      expect(@lot_stock.archived_quantity).to eq(0)
      @lot_archive.quantity = 100
      @lot_archive.save
      expect(@lot_stock.quantity).to eq(1400)
      expect(@lot_stock.archived_quantity).to eq(100)
      expect(@lot_archive.quantity).to eq(100)
    end

    it 'returns archive quantity' do
      expect(@lot_stock.quantity).to eq(1500)
      expect(@lot_stock.archived_quantity).to eq(0)
      @lot_archive.quantity = 100
      @lot_archive.save
      expect(@lot_stock.quantity).to eq(1400)
      expect(@lot_stock.archived_quantity).to eq(100)
      expect(@lot_archive.quantity).to eq(100)
      @lot_archive.return_by(@user)
      expect(@lot_stock.quantity).to eq(1500)
      expect(@lot_stock.archived_quantity).to eq(0)
      expect(@lot_archive.quantity).to eq(0)
    end
  end
end