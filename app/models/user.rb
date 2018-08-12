class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
  devise :database_authenticatable, :authentication_keys => [:username]

  # Relaciones
  belongs_to :sector
  has_many :internal_orders, -> { with_deleted }, foreign_key: "responsable_id"
  has_one :profile, :dependent => :destroy
  has_one :professional, :dependent => :destroy

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :professional

  after_create :create_profile

  def create_profile
    Profile.create(user: self)
  end

  def full_name
    if self.profile.last_name?
      self.profile.full_name
    else
      self.username
    end
  end

  def name_and_sector
    self.full_name+" | "+self.sector.sector_name
  end
end
