require 'rails_helper'

RSpec.describe Unity, type: :model do
  it 'does not create' do
    unity = Unity.new
    expect(unity.save).to be false
  end

  it 'does create' do
    unity = build(:unity)
    expect(unity.save).to be true
  end

  # attributes
  it 'has name' do
    unity = build(:aerosol_unity)
    expect(unity.name).to eq('Aerosol')
  end

  # validations
  it 'name cannot be blank' do
    unity = Unity.new
    expect { unity.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                          'La validación falló: Nombre no puede estar en blanco')
  end
end
