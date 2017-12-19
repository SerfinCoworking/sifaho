# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
joeUser = User.new(
  :email                 => "joe@example.com",
  :password              => "12345678",
  :password_confirmation => "12345678"
)
joeUser.add_role :admin
joeUser.save!
User.create!(
  :email                 => "jane@example.com",
  :password              => "12345678",
  :password_confirmation => "12345678"
)
Laboratory.create!(
  :name       => "Bayer",
  :address    => "Munro, Provincia de Buenos Aires"
)
MedicationBrand.create!(
  :name           => "Actron",
  :description    => "Contiene 400mg de Ibuprofeno y actúa más rápido que los comprimidos tradicionales",
  :laboratory_id  => 1
)
Vademecum.create!(
  :level_complexity   => 2,
  :specialty_enabled  => "MG",
  :medication_name    => "IBUPROFENO 400 MG comp",
  :indications        => "Analgesico y anti-inflamatorio. Riesgo de HDA dosis dependiente."
)
Medication.create!(
  :quantity         => 20,
  :expiry_date      => Time.now,
  :date_received    => Time.now,
  :vademecum        => Vademecum.first,
  :medication_brand => MedicationBrand.first
)
Supply.create!(
  :name             => "Leche",
  :quantity         => 40,
  :expiry_date      => Time.now,
  :date_received    => Time.now
)
Supply.create!(
  :name             => "Muletas",
  :quantity         => 5,
  :expiry_date      => Time.now,
  :date_received    => Time.now
)
patientType = PatientType.create!(
  :name         => "Ambulatorio",
  :description  => "Está recibiendo servicios del departamento de emergencia."
)
Patient.create!(
  :first_name       => "Juan",
  :last_name        => "Perez",
  :dni              => 12345678,
  :address          => "Elordi 343, San Martin de los Andes",
  :email            => "eljuan@gmail.com",
  :phone            => "02972432543",
  :patient_type_id  => patientType.id
)
Professional.create!(
  :first_name     => "Pablo",
  :last_name      => "Santillan",
  :dni            => 12345678,
  :enrollment     => "5336",
  :address        => "Sarmiento 489, San Martin de los Andes",
  :email          => "elpablito@gmail.com",
  :phone          => "0297223412"
)
PrescriptionStatus.create!(
  :name     => "Pendiente"
)
PrescriptionStatus.create!(
  :name     => "Dispensada"
)
PrescriptionStatus.create!(
  :name     => "Vencida"
)
