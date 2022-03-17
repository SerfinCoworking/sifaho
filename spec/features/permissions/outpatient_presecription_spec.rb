require 'rails_helper'

RSpec.feature 'OutpatientPrescriptions', type: :feature do

  background do
    @user = create(:user_1)
    @permission_module = create(:permission_module, name: 'Recetas Ambulatorias')
    @create_recipe_permission = create(:permission, name: 'create_outpatient_recipes', permission_module: @permission_module)
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_username', with: @user.username
      fill_in 'user_password', with: @user.password
    end
    click_button 'Iniciar sesión'
  end

  describe 'GET / (home page)', js: true do

    subject { page }

    it 'does not show "Recetas" link button' do
      visit '/'
      should_not have_link('Recetas', href: new_prescription_path)
    end
    
    describe 'GET /recetas (recipes page)' do
      before(:each) do
        permission = create(:permission, name: 'read_outpatient_recipes', permission_module: @permission_module)
        PermissionUser.create(user: @user, sector: @user.sector, permission: permission)
      end

      it 'shows "Recetas" link button' do
        visit '/'
        should have_link('Recetas', href: new_prescription_path)
      end

      describe 'Create action outpatient recipe' do
        before(:each) do
          visit '/'
          click_link 'Recetas'
          within '#new_patient' do
            expect(page.has_css?('input#patient-dni')).to be true
            page.execute_script %Q{$('#patient-dni').focus().val('37458994').keydown()}

            sleep 2
          end
          find('ul.ui-autocomplete').should have_content('37458994')
          page.execute_script("$('.ui-menu-item:contains(\"37458994\")').first().click()")
          sleep 2
          find_button('Guardar paciente').click
        end

        it 'does not show "+ Ambulatoria" link button' do
          expect(page.has_css?('#new-outpatient')).to be false
        end
        
        describe 'Create action outpatient recipe' do
          before(:each) do
            PermissionUser.create(user: @user, sector: @user.sector, permission: @create_recipe_permission)
          end
          
          it 'shows "+ Ambulatoria" link button' do
            expect(page.has_css?('#new-outpatient')).to be true  
          end
        end
      end

    end
  end
end