class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
  devise :database_authenticatable, :authentication_keys => [:username]

  # Relaciones
  belongs_to :sector
  has_one :profile, :dependent => :destroy
  has_one :professional, :dependent => :destroy

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :professional

  after_create :create_profile

  def create_profile
    Profile.create(user: self)
  end

  scope :with_sector_id, lambda { |an_id|
    where(sector_id: [*an_id])
  }

  def full_name
    if self.profile.last_name?
      self.profile.full_name
    else
      self.username
    end
  end

  def name_and_sector
    self.full_name+" | "+self.sector.name
  end

  def sector_name
    self.sector.name
  end

  def establishment_name
    self.sector.establishment_name
  end
end
