FactoryBot.define do
  factory :patient_type do
    description {''}

    trait :amb do
      name { 'Ambulatorio' }
    end
    
    trait :int do
      name { 'Cuidados Intensivos' }
    end
    
    trait :hos do
      name { 'Hospitalizado' }
    end
    
    trait :est do
      name { 'Estéril' }
    end
    
    trait :ped do
      name { 'Pediátrico' }
    end

    trait :cro do
      name { 'Crónico' }
    end

    factory :ambulatorio, traits: [:amb]
    factory :intensivo, traits: [:int]
    factory :hospitalizado, traits: [:hos]
    factory :esteril, traits: [:est]
    factory :pediatrico, traits: [:ped]
    factory :cronico, traits: [:cro]
  end
end
