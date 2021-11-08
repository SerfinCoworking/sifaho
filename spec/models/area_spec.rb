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
end
