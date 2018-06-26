class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
  devise :database_authenticatable, :authentication_keys => [:username]

  # Relaciones
  belongs_to :sector
  has_many :internal_orders, foreign_key: "responsable_id"
  has_one :profile, :dependent => :destroy

  after_create :create_profile

  def create_profile
    Profile.create(user: self)
  end
end
