FactoryBot.define do
  factory :sector do
    name { 'Informática' }
    description { 'Sector de informática del HSMA' }
    establishment

    trait :hdj_establishment do 
      association :establishment, factory: :hospital_establishment
    end

    factory :informatica_sector, traits: [:hdj_establishment]
  end
end
