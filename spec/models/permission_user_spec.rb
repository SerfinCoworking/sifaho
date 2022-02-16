require 'rails_helper'

RSpec.describe PermissionUser, type: :model do
  context 'on build' do
    before(:each) do
      @permission_user = build(:permission_user)
    end

    it 'belongs to user' do
      expect(@permission_user).to belong_to(:user)
    end
    
    it 'belongs to sector' do
      expect(@permission_user).to belong_to(:sector)
    end
    
    it 'belongs to permission' do
      expect(@permission_user).to belong_to(:permission)
    end
  end
end
