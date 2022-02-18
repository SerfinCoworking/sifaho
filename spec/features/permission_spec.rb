require 'rails_helper'

RSpec.feature 'Permissions', type: :feature do

  background do
    @user = create(:user_1)
    @permission_module = create(:permission_module, name: 'Usuario')
  end

  describe 'GET / (home page)' do
    before(:each) do
      permission = create(:permission, name: 'read_user', permission_module: @permission_module)
      PermissionUser.create(user: @user, sector: @user.sector, permission: permission)
      visit '/users/sign_in'
      within('#new_user') do
        fill_in 'user_username', with: 00002222
        fill_in 'user_password', with: 'password'
      end
      click_button 'Iniciar sesión'
    end

    subject { page }

    it 'shows user link button' do
      visit '/'
      should have_link('Usuarios', href: users_admin_index_path)
    end

    describe 'GET /usuarios (users page)' do
      before(:each) do
        click_link 'Usuarios'
      end

      it 'shows users table list' do
        expect(page).to have_css('table th', text: 'Usuario')
      end

      # User details
      it 'visit a user show page' do
        within "#user_#{@user.id}" do
          first('[data-detail]').click
        end
        expect(page).to have_content("Viendo usuario #{@user.full_name}")
      end

      # Users permissions
      it 'visit a user permission' do
        permission = create(:permission, name: 'update_permissions', permission_module: @permission_module)
        PermissionUser.create(user: @user, sector: @user.sector, permission: permission)
        visit current_path
        within "#user_#{@user.id}" do
          first('[data-permissions]').click
        end
        expect(page).to have_content("Editando permisos de #{@user.full_name}")
      end

      it 'visit a user edit permission without permission' do
        expect(page).not_to have_selector('[data-permissions]')
        visit "/usuarios/#{@user.id}/permisos"
        expect(page).to have_content('Usted no está autorizado para realizar esta acción.')
      end
    end
  end
end
