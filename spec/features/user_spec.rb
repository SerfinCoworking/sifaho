require 'rails_helper'

RSpec.feature 'Users', type: :feature do
  
  background do
    @correct_user = create(:user_1)
    farmaceutico_role = create(:role_farmaceutico)
    @correct_user.roles << farmaceutico_role
    @correct_user.save
    create(:user)
  end

  describe 'GET /sigin' do
    it 'returns http success' do
      visit '/users/sign_in'
      expect(page).to have_title('SIFAHO')
      expect(page).to have_text('Hola, te damos la bienvenida al Sistema Farmacéutico Hospitalario!')
    end
  end

  scenario 'Signing in with correct credentials' do
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_username', with: 00002222
      fill_in 'user_password', with: 'password'
    end
    click_button 'Iniciar sesión'
    # Agregar el rol
    expect(page).to have_content(@correct_user.full_name.to_s)
  end

  scenario 'Signing in with correct credentials without sector' do
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_username', with: 12345678
      fill_in 'user_password', with: 'password'
    end
    click_button 'Iniciar sesión'
    expect(page).to have_content('Solicitud de permisos')
    expect(page).to have_content('Complete el formulario para comenzar a utilizar el sistema.
      ')

    expect(page).to have_content('¿A cuál establecimiento pertenece?')
    expect(page).to have_content('¿A cuál sector pertenece?')
    expect(page).to have_content('¿Qué rol cumple?')
    expect(page).to have_content('Observaciones')
    expect(page).to have_content('Una vez enviado, deberá esperar a que algún gestor de usuarios responda la solicitud.
      Gracias por su paciencia.')

    within('#new_permission_request') do
      fill_in 'permission_request_establishment', with: 'Dr. Ramón Carrillo'
      fill_in 'permission_request_sector', with: 'Farmacia'
      fill_in 'permission_request_role', with: 'Farmacéutico'
      fill_in 'permission_request_observation', with: 'Prueba de observación.'
    end
    click_button 'Enviar'

    expect(page).to  have_content('La solicitud de permisos de ha enviado correctamente.')
    expect(page).to  have_content('Espere una respuesta')

  end

  given(:other_user) { create(:it_user) }

  scenario 'Signing in as another user' do
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_username', with: 00001111
      fill_in 'user_password', with: 'incorrect_password'
    end
    click_button 'Iniciar sesión'
    expect(page).to have_content('Usuario o contraseña incorrectos.')
  end
end
