require 'rails_helper'

RSpec.describe Lot, type: :model do
  it 'does not create' do
    lot = Lot.new
    expect(lot.save).to be false
  end
  
  it 'create' do
    # lot = Lot.new
    # expect(lot.save).to be false
  end
end
