require 'rails_helper'

# Test suite for User model
RSpec.describe User, type: :model do

  it 'does not create' do
    user = User.new
    expect(user.save).to be false
  end

  it 'does create' do
    user = build(:simple_user)
    expect(user.save).to be true
  end

  # Validation tests
  it { should validate_presence_of(:username) }

  # Delegate
  context 'created' do
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
  end

  # Relationship
  it 'has sector' do
    user = create(:it_user)
    expect(user.sector_name).to eq('Informática')
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