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

janeUser = User.new(
  :email                 => "jane@example.com",
  :password              => "12345678",
  :password_confirmation => "12345678"
)
janeUser.save!

labo = Laboratory.new(
  :name       => "Bayer",
  :address    => "Munro, Provincia de Buenos Aires"
)
labo.save!

brand = MedicationBrand.new(
  :name           => "Actron",
  :description    => "Contiene 400mg de Ibuprofeno y actúa más rápido que los comprimidos tradicionales",
  :laboratory_id  => 1
)
brand.save!

vademecum = Vademecum.new(
  :level_complexity   => 2,
  :specialty_enabled  => "MG",
  :medication_name    => "IBUPROFENO 400 MG comp",
  :indications        => "Analgesico y anti-inflamatorio. Riesgo de HDA dosis dependiente."
)
vademecum.save!

medication = Medication.new(
  :quantity         => 20,
  :expiry_date      => Time.now,
  :date_received    => Time.now,
  :vademecum        => Vademecum.first,
  :medication_brand => MedicationBrand.first
)
medication.save!

supply = Supply.new(
  :name             => "Leche",
  :quantity         => 40,
  :expiry_date      => Time.now,
  :date_received    => Time.now
)
supply.save!

patientType = PatientType.new(
  :name         => "Ambulatorio",
  :description  => "Está recibiendo servicios del departamento de emergencia."
)
patientType.save!

patient = Patient.new(
  :first_name       => "Juan",
  :last_name        => "Perez",
  :dni              => 12345678,
  :address          => "Elordi 343, San Martin de los Andes",
  :email            => "eljuan@gmail.com",
  :phone            => "02972432543",
  :patient_type_id  => patientType.id
)
patient.save!

medic = Professional.new(
  :first_name     => "Pablo",
  :last_name      => "Santillan",
  :dni            => 12345678,
  :enrollment     => "5336",
  :address        => "Sarmiento 489, San Martin de los Andes",
  :email          => "elpablito@gmail.com",
  :phone          => "0297223412"
)
medic.save!
