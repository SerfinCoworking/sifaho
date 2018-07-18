Sector.create!([
  { sector_name: "Informática", description: "Soporte en informatica", complexity_level: 3 },
  { sector_name: "Depósito", description: "Dispensación de insumos y drogas a todo el hospital", complexity_level: 3 },
  { sector_name: "Farmacia", description: "Dispensación de insumos y drogas a los pacientes del hospital", complexity_level: 3 },
  { sector_name: "Traumatología", description: "Se enfoca en el sistema oseomuscular", complexity_level: 3 },
  { sector_name: "Oftalmología", description: "Se enfoca en el sistema ocular", complexity_level: 2 },
  { sector_name: "Pediatría", description: "Medicina general de niños", complexity_level: 2 }
])
ProfessionalType.create!([
  { name: "Informática" },
  { name: "Depósito" },
  { name: "Farmacia" },
  { name: "Traumatología" },
  { name: "Oftalmología" },
  { name: "Pediatría" }
])
Professional.create!([
  { first_name: "Eugenio", last_name: "Gómez", dni: 12345678, professional_type_id: 1,
    sector_id: 1, email: "eugesma@gmail.com", phone: "422862"},
  { first_name: "Pablo", last_name: "Santillan", dni: 12345678, enrollment: "5336", professional_type_id: 4,
    sector_id: 4, email: "elpablito@gmail.com", phone: "0297223412" },
  { first_name: "Marina", last_name: "Petersen", dni: 23412342, enrollment: "6754", professional_type_id: 5,
    sector_id: 5, email: "lamari@gmail.com", phone: "0297436893" },
  { first_name: "Jorge", last_name: "Bo", dni: 22456789, enrollment: "9472", professional_type_id: 6,
    sector_id: 6, email: "elbojo@gmail.com", phone: "0297432157" }
])
eugeUser = User.new(
  :username              => "eugesma",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector_id             => 1
)
eugeUser.add_role :admin
eugeUser.save!
User.create!( username: "damian", password: "12345678", password_confirmation: "12345678", sector_id: 1)
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
PatientType.create!([
  { name: "Ambulatorio", description: "Está recibiendo servicios del departamento de emergencia."},
  { name: "Cuidados intensivos", description: "Está recibiendo servicios del departamento de emergencia."},
  { name: "Esteril", description: "Incapaz de procrear."}
])
PrescriptionStatus.create!([
  { name: "Pendiente" },
  { name: "Dispensada" },
  { name: "Vencida" }
])
