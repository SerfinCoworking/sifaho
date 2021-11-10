FactoryBot.define do
  factory :laboratory do
    name { 'ABBVIE SA' }
    cuit { '30500846301' }
    gln { '7790440000007' }

    trait :abbott do
      name { 'ABBOTT LABORATORIES ARGENTINA S.A.' }
    end

    factory :abbott_laboratory, traits: [:abbott]
  end
end
