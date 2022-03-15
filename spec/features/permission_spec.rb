require 'rails_helper'

RSpec.feature 'Permissions', type: :feature do

  background do
    @user = create(:user_1)
    @permission_module = create(:permission_module, name: 'Usuario')
    permission = create(:permission, name: 'read_users', permission_module: @permission_module)
    PermissionUser.create(user: @user, sector: @user.sector, permission: permission)
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_username', with: @user.username
      fill_in 'user_password', with: @user.password
    end
    click_button 'Iniciar sesión'
  end

  describe 'GET / (home page)', js: true do

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
          expect(page).to have_selector('.perm-mod-toggle-button', visible: false)
        end

        it 'has a toggle button each permisison' do
          expect(page).to have_selector('.perm-toggle-button', visible: false)
        end

        it 'has users permissions enable' do
          ru_permission = Permission.find_by(name: 'update_permissions')
          expect(page.find("#perm-check-#{ru_permission.id}", visible: false)).to be_checked
        end

        it 'enable or disable permissions' do
          user_mod_permission = PermissionModule.find_by(name: 'Usuario')
          expect(page.find("#perm-mod-check-#{user_mod_permission.id}", visible: false)).not_to be_checked

          find(:label, text: 'Todos', for: "perm-mod-check-#{user_mod_permission.id}").click
          expect(page.find("#perm-mod-check-#{user_mod_permission.id}", visible: false)).to be_checked
        end

        it 'on enable / disable permission module, check / uncheck all permissions module' do
          user_mod_permission = PermissionModule.find_by(name: 'Usuario')

          #check all 
          find(:label, text: 'Todos', for: "perm-mod-check-#{user_mod_permission.id}").click 
          user_mod_permission.permissions.each do |permission|
            expect(page.find("#perm-check-#{permission.id}", visible: false)).to be_checked
          end

          # uncheck all 
          find(:label, text: 'Todos', for: "perm-mod-check-#{user_mod_permission.id}").click
          user_mod_permission.permissions.each do |permission|
            expect(page.find("#perm-check-#{permission.id}", visible: false)).not_to be_checked
          end
        end

        describe "a user without permissions and sector" do
          before(:each) do
            @user_2 = create(:user)
            create(:sector_2)
            create(:sector_3)
            create(:sector_4)
            visit "/usuarios/#{@user_2.id}/permisos"
          end

          it 'displays a selector of sectors' do
            expect(page).to have_css('#remote_form_sector', visible: false)
          end

          it 'displays a sectors select modal, search a sector and remove / add one sector' do
            # check present elements
            expect(page).to have_css('#sector-selection', visible: false)
            expect(page).to have_css('#open-sectors-select-modal')
            find(:css, '#open-sectors-select-modal').click
            expect(page).to have_text('Selección de sectores')
            expect(page).to have_content('Sectores activos 0')
            within '#sector-selection' do

              # check "Select a sector" button, and filter
              expect(page.has_button?('Seleccionar sector')).to be true

              find_button('Seleccionar sector').click
              expect(page.has_css?('ul', class: 'dropdown-menu', visible: true)).to be true
              Sector.all.each do |sector|
                expect(page.has_css?('.dropdown-item', text: "#{sector.name} - #{sector.establishment_name}", visible: true)).to be true
              end

              expect(page.has_css?('input#remote_form_sector_selector_inp_search')).to be true

              find_field(id: 'remote_form_sector_selector_inp_search').set('Internación')

              # check Sector addition
              Sector.where(name: 'Internación').each do |sector|
                expect(page.has_css?('.dropdown-item', text: "#{sector.name} - #{sector.establishment_name}", visible: true)).to be true
              end

              Sector.where.not(name: 'Internación').each do |sector|
                expect(page.has_css?('.dropdown-item', text: "#{sector.name} - #{sector.establishment_name}", visible: true)).to be false
              end

              internacion_sector = Sector.where(name: 'Internación').first
              find('li', text: "#{internacion_sector.name} - #{internacion_sector.establishment_name}").click

              expect(page.has_css?('.dropdown-item', text: "#{internacion_sector.name} - #{internacion_sector.establishment_name}", visible: true)).to be false
            end

            # check post Sector addition
            expect(page.has_css?('ul#available_sectors_container', visible: true)).to be true

            within '#available_sectors_container' do
              Sector.where(name: 'Internación').each do |sector|
                expect(page).to have_content("#{sector.name} - #{sector.establishment_name}")
              end
            end


          end
        end
      end
    end
  end
end
