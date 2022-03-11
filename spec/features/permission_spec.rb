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
        expect(page).to have_content('Editando permisos')
      end

      it 'visit a user edit permission without permission' do
        expect(page).not_to have_selector('[data-permissions]')
        visit "/usuarios/#{@user.id}/permisos"
        expect(page).to have_content('Usted no está autorizado para realizar esta acción.')
      end

      describe 'GET /usuarios/id/permisos (edit user permissions page)' do
        before(:each) do
          @permission = create(:permission, name: 'update_permissions', permission_module: @permission_module)
          PermissionUser.create(user: @user, sector: @user.sector, permission: @permission)
          visit "/usuarios/#{@user.id}/permisos"
        end

        it 'has title and user fullname' do
          # expect title
          expect(page).to have_content('Editando permisos')
          # expect User fullname & dni
          expect(page).to have_content(@user.full_name)
          expect(page).to have_content(@user.profile.dni)
        end

        it 'has permissions filter input' do
          # expect Search input
          expect(page).to have_selector('#remote_form_search_name')
        end

        it 'has permissions list' do
          # expect Permisisons group list
          expect(page).to have_selector('#permissions_list')
        end

        it 'has a toggle button each permisison' do
          # expect Permisisons group toggle button exist
          expect(page).to have_selector('.perm-mod-toggle-button')
        end

        it 'has a toggle button each permisison' do
          expect(page).to have_selector('.perm-toggle-button')
        end

        it 'has users permissions enable' do
          ru_permission = Permission.find_by(name: 'update_permissions')
          expect(page.find("#perm-check-#{ru_permission.id}")).to be_checked
        end

        it 'enable or disable permissions' do
          user_mod_permission = PermissionModule.find_by(name: 'Usuario')
          expect(page.find("#perm-mod-check-#{user_mod_permission.id}")).not_to be_checked
          find(:css, "#perm-mod-check-#{user_mod_permission.id}").set(true)

          expect(page.find("#perm-mod-check-#{user_mod_permission.id}")).to be_checked
        end

        describe "a user without permissions" do
          before(:each) do
            @user_2 = create(:user)
            visit "/usuarios/#{@user_2.id}/permisos"
          end

          # it 'on enable / disable permission module, check / uncheck all permissions module' do
          #   user_mod_permission = PermissionModule.find_by(name: 'Usuario')

          #   user_mod_permission.permissions.each do |permission|
          #     expect(page.find("#perm-check-#{permission.id}")).not_to be_checked
          #   end

          #   find(:css, "#perm-mod-check-#{user_mod_permission.id}").set(true)
          #   user_mod_permission.permissions.each do |permission|
          #     expect(page.find("#perm-check-#{permission.id}")).to be_checked
          #   end
          # end
          # it 'cannot set permissions a user without sector' do
            # fails, because needs javascript driver
            # find(:css, "#perm-check-#{@permission.id}").set(true)
            # expect(page.find("#perm-check-#{@permission.id}")).to be_checked
            # click_button 'Guardar'
            # expect(page).to have_content("No se pudo actualizar los permisos del usuario #{@user_2.full_name}")
          # end

          it 'displays a selector of sectors' do
            expect(page).to have_css('#remote_form_sector')
          end

          it 'displays a sectors select modal' do
            expect(page).to have_css('#sector-selection')
          end

          # it 'displays a select with sectors options' do
          #   find("#open-sectors-select-modal").click

          #   expect(page).to have_css('#sector-selection')
          # end
        end
      end
    end
  end
end
