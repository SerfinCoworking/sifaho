FactoryBot.define do
  factory :laboratory do
    name { 'ABBVIE SA' }
    cuit { '30500846301' }
    gln { '7790440000007' }

    trait :abbott do
      name { 'ABBOTT LABORATORIES ARGENTINA S.A.' }
    end

    trait :abbvie do
      name { 'ABBVIE S.A.' }
    end

    trait :genomma do
      name { 'GENOMMA LABORATORIES ARGENTINA S.A.' }
    end

    factory :abbott_laboratory, traits: [:abbott]
    factory :abbvie_laboratory, traits: [:abbvie]
    factory :genomma_laboratory, traits: [:genomma]
  end
end
