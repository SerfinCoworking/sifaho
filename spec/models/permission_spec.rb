require 'rails_helper'

RSpec.describe Permission, type: :model do
  context 'build' do    
    before(:each) do
      @permission = build(:permission, name: 'create_sector')
    end
      
    it 'has name' do
      expect(@permission.name).to eq('create_sector')
    end

    it 'belongs to permission module' do
      expect(@permission).to belong_to(:permission_module)
    end
  end

  context 'on create' do
    before(:each) do
      @permission = build(:permission)  
      @permission_module = create(:permission_module, name: 'Sector')
    end

    it 'incorrect object should not been save' do
      expect(@permission.save).to be(false)
    end
    
    it 'name should be require' do
      @permission.permission_module = @permission_module
      expect { @permission.save! }.to raise_error(ActiveRecord::RecordInvalid,
        'La validación falló: Nombre no puede estar en blanco')
    end
    
    it 'permission_module should be require' do
      @permission.name = 'create_sector'
      expect { @permission.save! }.to raise_error(ActiveRecord::RecordInvalid,
        'La validación falló: Módulo debe existir')
    end

    it 'correct object should been save' do
      @permission.name = 'create_sector'
      @permission.permission_module = @permission_module
      expect(@permission.save).to be(true)
    end
  end
end
