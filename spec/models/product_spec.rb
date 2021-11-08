require 'rails_helper'

RSpec.describe Product, type: :model do
  it 'does not create' do
    product = Product.new
    expect(product.save).to be false
  end

  it 'does create' do
    product = build(:unidad_product)
    expect(product.save).to be true
  end

  # attributes
  it 'has name' do
    product = build(:unidad_product, name: 'Ibuprofeno 500mg')
    expect(product.name).to eq('Ibuprofeno 500mg')
  end

  it 'has code' do
    product = build(:unidad_product, code: '1111')
    expect(product.code).to eq('1111')
  end

  it 'has unity' do
    product = build(:unidad_product)
    expect(product.unity.name).to eq('Unidad')
  end

  it 'has area' do
    product = build(:unidad_product)
    expect(product.area.name).to eq('Medicamentos')
  end

  # delegates
  it 'delegate unity name' do
    product = build(:unidad_product)
    expect(product.unity_name).to eq('Unidad')
  end

  it 'delegate area name' do
    product = build(:unidad_product)
    expect(product.area_name).to eq('Medicamentos')
  end

  # validations
  it 'unity is require' do
    medication_area = create(:medication_area)
    product = Product.new(code: '2222', name: 'Ibuprofeno 400mg', area: medication_area)
    expect { product.save! }.to raise_error(ActiveRecord::RecordInvalid, 
                                            'La validación falló: Unidad no puede estar en blanco')
  end

  it 'area is require' do
    unidad_unity = create(:unidad_unity)
    product = Product.new(code: '2222', name: 'Ibuprofeno 400mg', unity: unidad_unity)
    expect { product.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                            'La validación falló: Rubro no puede estar en blanco')
  end

  it 'name cannot be blank' do
    product = build(:unidad_product, code: '2222', name: nil)
    expect { product.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                            'La validación falló: Nombre no puede estar en blanco')
  end

  it 'code cannot be blank' do
    product = build(:unidad_product, code: nil, name: 'Ibuprofeno 500mg')
    expect { product.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                            'La validación falló: Código no puede estar en blanco')
  end

  it 'code cannot be repeated' do
    product = create(:unidad_product, code: '1234')
    product_duplicated_code = build(:unidad_product, code: '1234')
    expect { product_duplicated_code.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                                            'La validación falló: Código ya está en uso')
  end
end
