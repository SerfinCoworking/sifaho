# IMPORTANTE!!!!!:
# Antes de ejecutar el seed se debe comentar la linea 24 y 45 del modelo User (:create_profile)

establishment = Establishment.create(
  code: '8370',
  name: 'Dr. Ramón Carrillo',
  cuit: '30-67261806-8',
  domicile: 'San Martín y Cnel. Rohde',
  phone: '2972427211',
  email: 'dr.ramon.carrillo@example.com'
)

Establishment.create(
  code: '8370',
  name: 'Depósito',
  cuit: '30-6541263-8',
  domicile: 'San Martín y Cnel. Rohde',
  phone: '297246532156',
  email: 'deposito@example.com'
)

Establishment.create(
  code: '8370',
  name: 'Depósito Central',
  cuit: '30-6541263-8',
  domicile: 'San Martín y Cnel. Rohde',
  phone: '297246532156',
  email: 'deposito.central@example.com'
)

sectorInf = Sector.create!(
  name: "Informática",
  description: "Sector desarrollo y soporte informático",
  complexity_level: "10",
  user_sectors_count: "4",
  establishment_id: establishment.id
)

adminsitracion = Sector.create!(
  name: "Administración",
  description: "Sector administración del establecimiento",
  establishment_id: establishment.id
)

despacho = Sector.create!(
  name: "Despacho",
  description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's.",
  establishment_id: establishment.id
)

estadistica = Sector.create!(
  name: "Estadística",
  description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's.",
  establishment_id: establishment.id
)

finanzas = Sector.create!(
  name: "Finanzas",
  description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's.",
  establishment_id: establishment.id
)

hoteleria = Sector.create!(
  name: "Hotelería",
  description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's.",
  establishment_id: establishment.id
)


eugeUser = User.new(
  :username              => "38601813",
  :password              => "1234568",
  :password_confirmation => "1234568",
)

UserSector.create(user:eugeUser, sector: sectorInf)
eugeUser.add_role :admin
eugeUser.sector = sectorInf
eugeUser.save!

Profile.create(user: eugeUser, first_name: "Eugenio", last_name: "Gomez", email: "euge@exmaple.com", dni: "38601813")

paul = User.new(
  :username              => "37458993",
  :password              => "1234568",
  :password_confirmation => "1234568",
)

UserSector.create(user: paul, sector: sectorInf)
paul.add_role :admin
paul.sector = sectorInf
paul.save!

Profile.create(user: paul, first_name: "Paul", last_name: "ibaceta", email: "paul@exmaple.com", dni: "37458993")

sectors = [adminsitracion, despacho, estadistica, finanzas, hoteleria]
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


