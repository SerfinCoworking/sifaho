require 'rails_helper'

RSpec.feature 'Users', type: :feature do
  
  background do
    create(:user_1)
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
    # expect(page).to have_content('Inicio Sectores')
    expect(page).to have_content('Iniciaste sesión correctamente.')
  end

  given(:other_user) { create(:user) }

  scenario 'Signing in as another user' do
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_username', with: 12345678
      fill_in 'user_password', with: 'password'
    end
    click_button 'Iniciar sesión'
    expect(page).to have_content('Usuario o contraseña incorrectos.')
  end
end
