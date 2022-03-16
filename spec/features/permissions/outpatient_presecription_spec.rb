require 'rails_helper'

RSpec.feature 'OutpatientPrescriptions', type: :feature do

  background do
    @user = create(:user_1)
    @permission_module = create(:permission_module, name: 'Recetas Ambulatorias')
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
          click_link 'Recetas'
          within '#new_patient' do
            fill_in 'patient-dni', with: 37458994
            within '#ui-id-2' do
              find('li.ui-menu-item').first.click
            end
            find('#patient-submit').click
          end
        end

        it 'does not show "+ Ambulatoria" link button' do
          # should

        end

        # describe 'Create action outpatient recipe' do
        #   before(:each) do
            
        #   end
        
          
        #   it 'shows "+ Ambulatoria" link button' do
            
        #   end
        # end
      end

    end
  end
end