FactoryBot.define do
  factory :sector do
    name { 'Informática' }
    description { 'Sector de informática del HSMA' }
    establishment

    trait :sec_1 do
      name { 'Farmacia' }
      description { 'Sector de farmacia del HSMA' }
      association :establishment, factory: :establishment_1
    end

    trait :sec_2 do
      name { 'Depósito' }
      description { 'Sector de depósito del HSMA' }
      association :establishment, factory: :establishment_2
    end

    trait :sec_3 do
      name { 'Internación' }
      description { 'Sector de Internación del HSMA' }
    end

    trait :hdj_establishment do 
      association :establishment, factory: :hospital_establishment
    end

    factory :informatica_sector, traits: [:hdj_establishment]
    factory :sector_1, traits: %i[sec_1]
    factory :sector_2, traits: %i[sec_2]
    factory :sector_3, traits: %i[sec_3]
  end
end
