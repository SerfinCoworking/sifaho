require 'rails_helper'

RSpec.describe Laboratory, type: :model do
  it 'does not create' do
    lot = Laboratory.new
    expect(lot.save).to be false
  end

  it 'create' do
    lot = build(:laboratory)
    expect(lot.save).to be true
  end

  # attributes
  it 'has name' do
    lot = build(:laboratory, name: 'Laboratorio de pruebas')
    expect(lot.name).to eq('Laboratorio de pruebas')
  end

  it 'has cuit' do
    lot = build(:laboratory, cuit: '40500846311')
    expect(lot.cuit).to eq(40500846311)
  end

  it 'has gln' do
    lot = build(:laboratory, gln: '8890440000008')
    expect(lot.gln).to eq(8890440000008)
  end

  # validations
  it 'name cannot be blank' do
    lot = build(:laboratory, name: nil)
    expect { lot.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                        'La validación falló: Razón social no puede estar en blanco')
  end

  it 'cuit cannot be blank' do
    lot = build(:laboratory, cuit: nil)
    expect { lot.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                        'La validación falló: Cuit no puede estar en blanco')
  end

  it 'gln cannot be blank' do
    lot = build(:laboratory, gln: nil)
    expect { lot.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                        'La validación falló: GLN no puede estar en blanco')
  end
end
