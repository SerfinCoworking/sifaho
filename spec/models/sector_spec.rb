require 'rails_helper'

RSpec.describe Sector, type: :model do
  it 'does not create' do
    sector = Sector.new
    expect(sector.save).to be false
  end

  it 'does create' do
    sector = build(:informatica_sector)
    expect(sector.save).to be true
  end

  # attribute
  it 'has name' do
    sector = build(:informatica_sector)
    expect(sector.name).to eq('Informática')
  end

  it 'has description' do
    sector = build(:informatica_sector)
    expect(sector.description).to eq('Sector de informática del HSMA')
  end

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:establishment) }
  
  it 'name cannot be blank' do
    sector = build(:informatica_sector, name: nil)
    expect { sector.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                           'La validación falló: Nombre no puede estar en blanco')
  end


  it 'establishment cannot be blank' do
    sector = build(:informatica_sector, establishment: nil)

    expect { sector.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                           'La validación falló: Establecimiento debe existir, Establecimiento no puede estar en blanco')
  end

  # delegate
  it 'has establishment name / short name' do
    sector = build(:informatica_sector)
    expect(sector.establishment_name).to eq('Dr. Juan Hospital')
    expect(sector.establishment_short_name).to eq('DJH')
  end
end
