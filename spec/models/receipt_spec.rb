require 'rails_helper'

RSpec.describe Receipt, type: :model do
  it 'does not create' do
    receipt = Receipt.new
    expect(receipt.save).to be false
  end

  context 'build order' do
    before(:each) do
      @provider_sector = create(:sector_1)
      @applicant_sector = create(:sector_2)
      @product = create(:unidad_product)
      @receipt_product = build(:receipt_product_1, product: @product)
      @receipt = Receipt.new(provider_sector: @provider_sector, applicant_sector: @applicant_sector,
                             receipt_products: [@receipt_product], code: 'AA613')
    end

    it 'does create' do
      expect(@receipt.save!).to be true
    end

    it 'has provider establishment and sector' do
      expect(@receipt.provider_sector.establishment_name).to eq('Hospital Dr. Ramón Carrillo')
      expect(@receipt.provider_sector.name).to eq('Farmacia')
    end

    it 'has applicant establishment and sector' do
      expect(@receipt.applicant_sector.establishment_name).to eq('Hospital Dr. Pepito Perez')
      expect(@receipt.applicant_sector.name).to eq('Depósito')
    end

    it 'has a default status' do
      @receipt.save
      expect(@receipt.status).to eq('auditoria')
    end

    it 'has products' do
      @receipt.save
      @receipt_product.receipt = @receipt
      @receipt_product.save

      expect(@receipt.receipt_products.count).to eq(1)
      expect(@receipt.receipt_products.first.product_name).to eq('Ibuprofeno 1500mg')
    end

    # context 'receive order' do
    #   it '' do
        
    #   end
    # end
  end
end
