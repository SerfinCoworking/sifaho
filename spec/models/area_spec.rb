require 'rails_helper'

RSpec.describe Area, type: :model do
  it 'does not create' do
    area = build(:area)
    expect(area.save).to be false
  end

  it 'does create' do
    area = build(:medication_area)
    expect(area.save).to be true
  end

  #attribute
  it 'has name' do
    area = build(:medication_area)
    expect(area.name).to  eq('Medicamentos')
  end

  #validations
  it 'name cannot be blank' do
    area = Area.new
    expect { area.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                         'La validación falló: Nombre no puede estar en blanco')
  end
end
