Sector.create!([
  { sector_name: "Informática", description: "Soporte en informatica", complexity_level: 3 },
  { sector_name: "Depósito", description: "Dispensación de insumos y drogas a todo el hospital", complexity_level: 3 },
  { sector_name: "Farmacia", description: "Dispensación de insumos y drogas a los pacientes del hospital", complexity_level: 3 },
  { sector_name: "Traumatología", description: "Se enfoca en el sistema oseomuscular", complexity_level: 3 },
  { sector_name: "Oftalmología", description: "Se enfoca en el sistema ocular", complexity_level: 2 },
  { sector_name: "Pediatría", description: "Medicina general de niños", complexity_level: 2 }
])
eugeUser = User.new(
  :username              => "eugesma",
  :first_name            => "Eugenio",
  :last_name             => "Gómez",
  :email                 => "eugesma@gmail.com",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector_id             => 1,
  :gender                => 0
)
eugeUser.add_role :admin
eugeUser.save!
User.create!( username: "veronica", first_name: "Verónica", password: "12345678", password_confirmation: "12345678", sector_id: 2, gender: 1)
User.create!( username: "claudia", first_name: "Claudia", password: "12345678", password_confirmation: "12345678", sector_id: 3, gender: 1)
User.create!( username: "damian", first_name: "Damián", last_name: "Diez", email: "damianediez@gmail.com", password: "12345678", password_confirmation: "12345678", sector_id: 1, gender: 0)
Laboratory.create!([
  { name: "Bayer", address: "Munro, Provincia de Buenos Aires"},
  { name: "Droguería INTI S.A.", address: "Lucas Jaimes No. 1959, Buenos Aires"}
])
MedicationBrand.create!([
  { name: "Actron", laboratory_id: 1,
  description: "Contiene 400mg de Ibuprofeno y actúa más rápido que los comprimidos tradicionales" },
  { name: "Adrenalina", laboratory_id: 2,
  description: "Catecolamina simpaticomimética" }
])
Vademecum.create!([
  { level_complexity: 2, specialty_enabled: "MG", medication_name: "IBUPROFENO 400 MG comp",
    indications: "Analgesico y anti-inflamatorio. Riesgo de HDA dosis dependiente." },
  { level_complexity: 2, specialty_enabled: "MG", medication_name: "ADRENALINA 1 mg/ml ampollas",
    indications: "Anafilaxia. Crisis Asmática severa. Paro Cardio Respiratorio, asistolia, FV/TV, DEM." }
])
Medication.create!([
  { quantity: 20, expiry_date: DateTime.current + 2.year, date_received: DateTime.current, vademecum_id: 1,
    medication_brand: MedicationBrand.first },
  { quantity: 15, expiry_date: DateTime.current + 1.year, date_received: DateTime.current, vademecum_id: 2,
    medication_brand: MedicationBrand.find(2) },
])
Supply.create!([
  { name: "Leche", quantity: 40, expiry_date: DateTime.current + 4.month, date_received: DateTime.current },
  { name: "Muletas", quantity: 5, expiry_date: DateTime.current + 10.year, date_received: DateTime.current }
])
PatientType.create!([
  { name: "Ambulatorio", description: "Está recibiendo servicios del departamento de emergencia."},
  { name: "Cuidados intensivos", description: "Está recibiendo servicios del departamento de emergencia."},
  { name: "Esteril", description: "Incapaz de procrear."}
])
Patient.create!( first_name: "Juan", last_name: "Perez", dni: 12345678,
  address: "Elordi 343, San Martin de los Andes", email: "eljuan@gmail.com",
  phone: "02972432543", patient_type_id: 1
)
Professional.create!([
  { first_name: "Pablo", last_name: "Santillan", dni: 12345678, enrollment: "5336", sector_id: 1,
    address: "Sarmiento 489, San Martin de los Andes", email: "elpablito@gmail.com", phone: "0297223412" },
  { first_name: "Marina", last_name: "Petersen", dni: 23412342, enrollment: "6754", sector_id: 2,
    address: "Elordi 213, San Martin de los Andes", email: "lamari@gmail.com", phone: "0297436893" },
  { first_name: "Jorge", last_name: "Bo", dni: 22456789, enrollment: "9472", sector_id: 3,
    address: "Rivadavia 394, San Martin de los Andes", email: "elbojo@gmail.com", phone: "0297432157" }
])
PrescriptionStatus.create!([
  { name: "Pendiente" },
  { name: "Dispensada" },
  { name: "Vencida" }
])
