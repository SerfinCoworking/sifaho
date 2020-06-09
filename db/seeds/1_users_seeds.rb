# IMPORTANTE!!!!!:
# Antes de ejecutar el seed se debe comentar la linea 24 y 45 del modelo User (:create_profile)

# Establecimiento de San martin de los Andes
establishmentSanMartin = Establishment.create(
  code: '8370',
  name: 'Dr. Ramón Carrillo',
  cuit: '30-67261806-8',
  domicile: 'San Martín y Cnel. Rohde',
  phone: '2972427211',
  email: 'dr.ramon.carrillo@example.com',
  sectors_count: '4'
)
# Establecimiento de Junin Example
establishmentJunin = Establishment.create(
  code: '8370',
  name: 'Hospital junin',
  cuit: '30-67549606-8',
  domicile: 'Cnel. Rohde',
  phone: '2972478911',
  email: 'hospital.junin@example.com',
  sectors_count: '4'
)
##########################
#sector Informatica Establecimiento de San martin de los Andes
sectorInf = Sector.create!(
  name: "Informática",
  description: "Sector desarrollo y soporte informático",
  complexity_level: "10",
  user_sectors_count: "4",
  establishment: establishmentSanMartin
)
#sector Medicos Establecimiento de San martin de los Andes
sectorMedic = Sector.create!(
  name: "Medicos",
  description: "Medicos del Hospital",
  complexity_level: "10",
  user_sectors_count: "6",
  establishment: establishmentSanMartin
)
#sector farmacia Establecimiento de San martin de los Andes
sectorFar = Sector.create!(
  name: "Farmacia",
  description: "Gestion de entraga de medicamentos",
  complexity_level: "10",
  user_sectors_count: "5",
  establishment: establishmentSanMartin
)
#sector Medicos Establecimiento de Junin
sectorMedicJunin = Sector.create!(
  name: "Medicos",
  description: "Medicos del Hospital",
  complexity_level: "10",
  user_sectors_count: "6",
  establishment: establishmentJunin
)
#sector farmacia Establecimiento de Junin
sectorFarJunin = Sector.create!(
  name: "Farmacia",
  description: "Gestion de entraga de medicamentos",
  complexity_level: "10",
  user_sectors_count: "5",
  establishment: establishmentJunin
)
##########################
# Creacion de usuarios
eugeUser = User.new(
  :username              => "38601813",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector             => sectorInf
)
eugeUser.add_role :admin
eugeUser.save!

Profile.create(user: eugeUser, first_name: "Eugenio", last_name: "Gomez", email: "euge@exmaple.com", dni: "38601813")

paul = User.new(
  :username              => "37458993",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector             => sectorInf
)
paul.add_role :admin
paul.save!
Profile.create(user: paul, first_name: "Paul", last_name: "ibaceta", email: "paul@exmaple.com", dni: "37458993")

farmaceuticoUser = User.new(
  :username              => "40579158",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector             => sectorFar
)
farmaceuticoUser.add_role :farmaceutico
farmaceuticoUser.save!
Profile.create(user: farmaceuticoUser, first_name: "farmaceutico", last_name: "one", email: "secretario@exmaple.com", dni: "40579158")

medicUser = User.new(
  :username              => "40671958",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector             => sectorMedic
)
medicUser.add_role :medic
medicUser.save!
Profile.create(user: medicUser, first_name: "medico", last_name: "one", email: "secretario@exmaple.com", dni: "40671958")
##########################
# Usuarios Hospital Junin Example
farmaceuticoUser = User.new(
  :username              => "12345678",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector             => sectorFarJunin
)
farmaceuticoUser.add_role :farmaceutico
farmaceuticoUser.save!
Profile.create(user: farmaceuticoUser, first_name: "farmaceutico", last_name: "one", email: "secretario@exmaple.com", dni: "40579158")

medicUser = User.new(
  :username              => "12345679",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector             => sectorMedicJunin
)
medicUser.add_role :medic
medicUser.save!
Profile.create(user: medicUser, first_name: "medico", last_name: "one", email: "secretario@exmaple.com", dni: "40671958")

#:admin 
#:farmaceutico 
#:auxiliar_farmacia 
#:medic 
#:enfermero