Sector.create!([
  { name: "Informática", description: "Soporte en informatica", complexity_level: 3 },
  { name: "Depósito", description: "Dispensación de insumos y drogas a todo el hospital", complexity_level: 3 },
  { name: "Farmacia", description: "Dispensación de insumos y drogas a los pacientes del hospital", complexity_level: 3 },
  { name: "Traumatología", description: "Se enfoca en el sistema oseomuscular", complexity_level: 3 },
  { name: "Oftalmología", description: "Se enfoca en el sistema ocular", complexity_level: 2 },
  { name: "Pediatría", description: "Medicina general de niños", complexity_level: 2 }
])

eugeUser = User.new(
  :username              => "eugesma",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector_id             => 1
)
eugeUser.add_role :admin
eugeUser.save!
