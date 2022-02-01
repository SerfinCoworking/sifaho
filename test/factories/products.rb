FactoryBot.define do
  factory :product do
    code { '0000' }
    name { 'Ibuprofeno 1500mg' }
    description { 'Ibuprofeno de 1500mg...' }
    unity
    area

    trait :unidad do
      association :unity, factory: :unidad_unity
    end

    trait :medication do
      association :area, factory: :medication_area
    end

    trait :prod_1 do
      association :area, factory: :medication_area
      association :unity, factory: :unidad_unity
      code { '1717' }
      name { 'Barbijo tableteado, triple capa, descartable' }
      description { 'Barbijo tableteado, tricapa, descartable, con cuatro tiras para fijación en posición.' }
    end
    
    trait :prod_2 do
      association :area, factory: :medication_area
      association :unity, factory: :unidad_unity
      code { '5790' }
      name { 'IBUPROFENO 2% jarabe	' }
      description { 'Envases conteniendo IBUPROFENO 2g/100 mL, en envases por 90mL.' }
    end

    factory :unidad_product, traits: [:unidad, :medication]
    factory :product_1, traits: [:prod_1]
    factory :product_2, traits: [:prod_2]
  end
end
