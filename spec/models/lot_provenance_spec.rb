require 'rails_helper'

RSpec.describe LotProvenance, type: :model do
  it 'does not create' do
    lot_provenance = LotProvenance.new
    expect(lot_provenance.save).to be false
  end

  it 'create' do
    lot_provenance = build(:province_lot_provenance)
    expect(lot_provenance.save).to be true
  end

  # attributes
  it 'has name' do
    lot_provenance = build(:lot_provenance, name: 'Prueba')
    expect(lot_provenance.name).to eq('Prueba')
  end

  # validations
  it 'name cannot be blank' do
    lot_provenance = build(:lot_provenance, name: nil)
    expect { lot_provenance.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                                   'La validación falló: Nombre no puede estar en blanco')
  end
end
