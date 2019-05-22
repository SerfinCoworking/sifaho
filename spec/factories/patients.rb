FactoryBot.define do
  factory :patient do
    dni { Faker::Number.number(9) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    patient_type { PatientType.first }
  end
end