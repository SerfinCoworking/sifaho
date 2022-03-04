require 'rails_helper'

# Test suite for User model
RSpec.describe User, type: :model do

  context 'on build' do
    before(:each) do
      @user = create(:simple_user)
    end

    it 'has profile fullname' do
      expect(@user.full_name).to eq('Reimann Test')
    end

    it 'has profile first_name' do
      expect(@user.full_name).to eq('Reimann Test')
    end

    it 'has profile dni' do
      expect(@user.dni).to eq(00001111)
    end

    it 'has profile email' do
      expect(@user.email).to eq('reimann@example.com')
    end

    it 'has many permissions' do
      expect(@user).to have_many(:permissions)
    end

    it 'has many sectors' do
      expect(@user).to have_many(:sectors)
    end

    it 'belongs to a sector (active)' do
      expect(@user).to belong_to(:sector)
    end
  end

  # Delegate
  context 'on create' do

    it 'incorrect object should not been save' do
      user = User.new
      expect(user.save).to be false
    end

    # Validation tests
    it { should validate_presence_of(:username) }

    it 'correct object should been save' do
      @user = build(:simple_user)
      expect(@user.save).to be true
    end
  end

  # Method
  context 'created with sector' do
    before(:each) do
      @user = create(:it_user)
    end

    it 'has name and sector' do
      expect(@user.name_and_sector).to eq('Reimann Test | Informática')
    end

    it 'has sector and establisment' do
      expect(@user.sector_and_establishment).to eq('Informática Dr. Juan Hospital')
    end
  end
end