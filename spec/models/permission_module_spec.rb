require 'rails_helper'

RSpec.describe PermissionModule, type: :model do
  context 'build' do
    before(:each) do
      @permission_module = build(:permission_module, name: 'Sector')
    end

    it 'has name' do
      expect(@permission_module.name).to eq('Sector')
    end
  end

  context 'on create' do
    
    before(:each) do
      @permission_module = build(:permission_module)  
    end

    it 'does not save' do
      expect(@permission_module.save).to be(false)
    end

    it 'name attribute should require' do
      expect { @permission_module.save! }.to raise_error(ActiveRecord::RecordInvalid,
        'La validación falló: Nombre no puede estar en blanco')
    end
  end
end
