# IMPORTANTE!!!!!:
# Antes de ejecutar el seed se debe comentar la linea 24 y 45 del modelo User (:create_profile)

##########################
sectorInformatico = Sector.find_by_name("Informática")
# Creacion de usuarios
eugeUser = User.new(
  :username              => "38601813",
  :password              => "12345678",
  :password_confirmation => "12345678",
)

UserSector.create(user:eugeUser, sector: sectorInformatico)
eugeUser.add_role :admin
eugeUser.sector = sectorInformatico
eugeUser.save!

Profile.create(user: eugeUser, first_name: "Eugenio", last_name: "Gomez", email: "euge@exmaple.com", dni: "38601813")

paul = User.new(
  :username              => "37458993",
  :password              => "12345678",
  :password_confirmation => "12345678",
)

UserSector.create(user: paul, sector: sectorInformatico)
paul.add_role :admin
paul.sector = sectorInformatico
paul.save!
Profile.create(user: paul, first_name: "Paul", last_name: "ibaceta", email: "paul@exmaple.com", dni: "37458993")

sectorFar =  Sector.where(establishment: Establishment.find_by_name("Dr. Ramón Carrillo"), name: "Farmacia").first
sectorFarJunin =  Sector.where(establishment: Establishment.find_by_name("Hospital junin"), name: "Farmacia").first
sectorMedic =  Sector.where(establishment: Establishment.find_by_name("Dr. Ramón Carrillo"), name: "Medicos").first
sectorMedicJunin =  Sector.where(establishment: Establishment.find_by_name("Hospital junin"), name: "Medicos").first

farmaceuticoUser = User.new(
  :username              => "40579158",
  :password              => "12345678",
  :password_confirmation => "12345678"
)

UserSector.create(user:farmaceuticoUser, sector: sectorFar)
farmaceuticoUser.add_role :farmaceutico
farmaceuticoUser.sector = sectorInformatico
farmaceuticoUser.save!
Profile.create(user: farmaceuticoUser, first_name: "farmaceutico", last_name: "one", email: "secretario@exmaple.com", dni: "40579158")

medicUser = User.new(
  :username              => "40671958",
  :password              => "12345678",
  :password_confirmation => "12345678"
)

UserSector.create(user:medicUser, sector: sectorMedic)
medicUser.add_role :medic
medicUser.sector = sectorInformatico
medicUser.save!
Profile.create(user: medicUser, first_name: "medico", last_name: "one", email: "secretario@exmaple.com", dni: "40671958")

##########################
# Usuarios Hospital Junin Example
farmaceuticoUser = User.new(
  :username              => "12345678",
  :password              => "12345678",
  :password_confirmation => "12345678",
)
UserSector.create(user:farmaceuticoUser, sector: sectorFarJunin)
farmaceuticoUser.add_role :farmaceutico
farmaceuticoUser.sector = sectorFarJunin
farmaceuticoUser.save!
Profile.create(user: farmaceuticoUser, first_name: "farmaceutico", last_name: "one", email: "secretario@exmaple.com", dni: "40579158")

medicUser = User.new(
  :username              => "12345679",
  :password              => "12345678",
  :password_confirmation => "12345678"
)
medicUser.add_role :medic
medicUser.sector = sectorMedicJunin
medicUser.save!
Profile.create(user: medicUser, first_name: "medico", last_name: "one", email: "secretario@exmaple.com", dni: "40671958")


# usuarios genericos
sectors = Sector.all
users_samples = [
  {:name => 'joe', :dni => "1234568"},
  {:name => 'charly', :dni => "1234569"},
  {:name => 'jane', :dni => "1234570"},
  {:name => 'jack', :dni => "1234571"},
  {:name => 'angie', :dni => "1234572"},
  {:name => 'Abigail', :dni => "1234573"},
  {:name => 'Alison', :dni => "1234574"},
  {:name => 'Carol', :dni => "1234575"},
  {:name => 'Donna', :dni => "1234576"},
  {:name => 'jhone', :dni => "1234577"},
  {:name => 'Emily', :dni => "1234578"},
  {:name => 'Jennifer', :dni => "1234579"},
  {:name => 'Lauren', :dni => "1234580"},
  {:name => 'Leah', :dni => "1234581"},
  {:name => 'Lillian', :dni => "1234582"},
  {:name => 'Lily', :dni => "1234583"},
  {:name => 'Lisa', :dni => "1234584"},
  {:name => 'Ruth', :dni => "1234585"},
  {:name => 'Sally', :dni => "1234586"},
  {:name => 'Samantha', :dni => "1234587"},
  {:name => 'Sarah', :dni => "1234588"},
  {:name => 'Sonia', :dni => "1234589"},
  {:name => 'Sophie', :dni => "1234590"},
  {:name => 'Charles', :dni => "1234591"},
  {:name => 'Christian', :dni => "1234592"},
  {:name => 'Christopher', :dni => "1234593"},
  {:name => 'Colin', :dni => "1234594"},
  {:name => 'Connor', :dni => "1234595"},
  {:name => 'Dan', :dni => "1234596"},
  {:name => 'David', :dni => "1234597"},
  {:name => 'Dominic', :dni => "1234598"},
  {:name => 'Dylan', :dni => "1234599"},
  {:name => 'Edward', :dni => "1234690"},
  {:name => 'Eric', :dni => "1234691"},
  {:name => 'Evan', :dni => "1234692"},
]

roles = [
  :farmaceutico,
  :auxiliar_farmacia,
  :farmaceutico_central,
  :instrumentalista_quirurgico,
  :medico,
  :gestor_usuario
]

users_samples.each do |user|
  new_user = User.new(
    :username              => user[:dni],
    :password              => "1234568",
    :password_confirmation => "1234568"
  )
  new_user.add_role roles.sample
  new_user.save!

  UserSector.create(user: new_user, sector: sectors.sample)

  Profile.create(user: new_user, first_name: user[:name], last_name: "smith", email: user[:name] + "@exmaple.com", dni: user[:dni])
end


#:admin
#:farmaceutico
#:auxiliar_farmacia
#:medic
#:enfermero
