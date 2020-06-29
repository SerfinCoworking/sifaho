# Creamos los establecimientos y sectores que necesitemos

# Establecimientos
establecimientoSanMartin = Establishment.create(
  code: '8370',
  name: 'Dr. Ramón Carrillo',
  cuit: '30-67261806-8',
  domicile: 'San Martín y Cnel. Rohde',
  phone: '2972427211',
  email: 'dr.ramon.carrillo@example.com'
)

estableciminetoJunin = Establishment.create(
  code: '8370',
  name: 'Hospital junin',
  cuit: '30-67549606-8',
  domicile: 'Cnel. Rohde',
  phone: '2972478911',
  email: 'hospital.junin@example.com',
  sectors_count: '4'
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

# Sectores
Sector.create!(
  name: "Informática",
  description: "Sector desarrollo y soporte informático",
  establishment: establecimientoSanMartin
)

Sector.create!(
  name: "Administración",
  description: "Sector administración del establecimiento",
  establishment: establecimientoSanMartin
)

Sector.create!(
  name: "Despacho",
  description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's.",
  establishment: establecimientoSanMartin
)

Sector.create!(
  name: "Estadística",
  description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's.",
  establishment: establecimientoSanMartin
)

Sector.create!(
  name: "Finanzas",
  description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's.",
  establishment: establecimientoSanMartin
)

Sector.create!(
  name: "Hotelería",
  description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's.",
  establishment: establecimientoSanMartin
)

Sector.create!(
  name: "Medicos",
  description: "Medicos del Hospital",
  establishment: establecimientoSanMartin
)

Sector.create!(
  name: "Farmacia",
  description: "Gestion de entraga de medicamentos",
  establishment: establecimientoSanMartin
)

Sector.create!(
  name: "Medicos",
  description: "Medicos del Hospital",
  establishment: estableciminetoJunin
)

Sector.create!(
  name: "Farmacia",
  description: "Gestion de entraga de medicamentos",
  establishment: estableciminetoJunin
)
