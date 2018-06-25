class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable,
         :trackable, :validatable

  # Relaciones
  belongs_to :sector
  has_many :internal_orders, foreign_key: "responsable_id"

  # Validaciones
  validates_presence_of :sector
end
