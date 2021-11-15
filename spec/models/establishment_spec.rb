require 'rails_helper'

RSpec.describe Establishment, type: :model do
  it 'does not create' do
    establishment = Establishment.new
    expect(establishment.save).to be false
  end

  it 'does create' do
    establishment = build(:hospital_establishment)
    expect(establishment.save).to be true
  end

  # attribute
  it 'has name' do
    establishment = build(:hospital_establishment)
    expect(establishment.name).to eq('Dr. Juan Hospital')
  end

  it 'has shortname' do
    establishment = build(:hospital_establishment)
    expect(establishment.short_name).to eq('DJH')
  end

  it 'has sanitary zone name' do
    establishment = build(:hospital_establishment)
    expect(establishment.sanitary_zone.name).to eq('Zona Sanitaria IV')
  end

  it 'has sanitary zone state name' do
    establishment = build(:hospital_establishment)
    expect(establishment.sanitary_zone.state.name).to eq('Neuquén')
  end

  it 'has sanitary zone state country name' do
    establishment = build(:hospital_establishment)
    expect(establishment.sanitary_zone.state.country.name).to eq('Argentina')
  end
  
  it 'has establishment type name' do
    establishment = build(:hospital_establishment)
    expect(establishment.establishment_type.name).to eq('Hospital')
  end

  # validation
  it 'name cannot be blank' do
    establishment = build(:hospital_establishment, name: nil)
    expect { establishment.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                                  'La validación falló: Nombre no puede estar en blanco')
  end

  it 'short name cannot be blank' do
    establishment = build(:hospital_establishment, short_name: nil)
    expect { establishment.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                                  'La validación falló: Nombre abreviado no puede estar en blanco')
  end
end
