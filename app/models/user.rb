class User < ApplicationRecord
  rolify

  enum gender: { masculino: 0, femenino: 1 }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
  devise :database_authenticatable, :authentication_keys => [:username]

  # Relaciones
  belongs_to :sector
  has_many :internal_orders, foreign_key: "responsable_id"

  # Validaciones
  validates_presence_of :username, uniqueness: true
  validates_presence_of :first_name
  validates_presence_of :gender
  # validates_presence_of :last_name
  # validates_presence_of :dni
  validates_presence_of :sector
end
