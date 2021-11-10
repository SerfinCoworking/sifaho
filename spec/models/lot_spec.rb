require 'rails_helper'

RSpec.describe Lot, type: :model do
  it 'does not create' do
    lot = Lot.new
    expect(lot.save).to be false
  end

  it 'create' do
    lot = build(:province_lot)
    expect(lot.save).to be true
  end

  # attribute
  it 'has expiry date' do
    lot = build(:province_lot, expiry_date: Date.new(2021, 11, 10))
    expect(lot.expiry_date).to eq(Date.new(2021, 11, 10))
  end

  it 'has code' do
    lot = build(:province_lot, code: '1234')
    expect(lot.code).to eq('1234')
  end

  it 'has a default status' do
    lot = build(:province_lot)
    expect(lot.status).to eq('vigente')
  end

  # validation
  it 'provenance cannot be blank' do
    lot = build(:province_lot, provenance: nil)
    expect { lot.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                        'La validación falló: Provenance no puede estar en blanco')
  end

  it 'uniqueness provenance / laboratory / code / expiry_date' do
    create(:province_lot)
    expect { build(:province_lot).save! }.to raise_error(ActiveRecord::RecordInvalid,
                                                         'La validación falló: Código ya está en uso')
  end

  # delegate
  it 'has laboratory' do
    lot = build(:province_lot)
    expect(lot.laboratory_name).to eq('ABBOTT LABORATORIES ARGENTINA S.A.')
  end

  it 'has product name' do
    lot = build(:province_lot)
    expect(lot.product_name).to eq('Ibuprofeno 1500mg')
  end

  it 'has product code' do
    lot = build(:province_lot)
    expect(lot.product_code).to eq('0000')
  end

  it 'has provenance' do
    lot = build(:province_lot)
    expect(lot.provenance_name).to eq('Provincia')
  end

  # methods
  it 'parse expiry_date to string' do
    lot = build(:province_lot, expiry_date: Date.new(2022, 11, 10))
    expect(lot.expiry_date_string).to eq('10/11/2022')
  end

  it 'parse expiry_date to short string' do
    lot = build(:province_lot, expiry_date: Date.new(2022, 11, 10))
    expect(lot.short_expiry_date_string).to eq('11/22')
  end

  it 'changes lot status from "vigente" to "vencido"' do
    lot = build(:province_lot, expiry_date: Date.new(2019, 11, 10))
    expect(lot.status).to eq('vigente')
    lot.update_status
    expect(lot.status).to eq('vencido')
  end

  it 'changes lot status from "vigente" to "por_vencer"' do
    lot = build(:province_lot, expiry_date: Date.current + 3.month)
    expect(lot.status).to eq('vigente')
    lot.update_status
    expect(lot.status).to eq('por_vencer')
  end

  # Relationship
  it 'has many lot_stocks' do
    
  end
end
