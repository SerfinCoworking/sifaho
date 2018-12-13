eugeUser = User.new(
  :username              => "eugesma",
  :password              => "12345678",
  :password_confirmation => "12345678",
  :sector_id             => 1
)
eugeUser.add_role :admin
eugeUser.save!
