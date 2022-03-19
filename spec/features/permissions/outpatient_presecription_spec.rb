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
      expect(page).to_not have_selector(:css, "a[href='#{new_prescription_path}']")
    end
    
    describe 'GET /recetas (recipes page)' do
      before(:each) do
        permission = create(:permission, name: 'read_outpatient_recipes', permission_module: @permission_module)
        PermissionUser.create(user: @user, sector: @user.sector, permission: permission)
      end

      it 'shows "Recetas" link button' do
        visit '/'
        expect(page).to have_selector(:css, "a[href='#{new_prescription_path}']")
      end

      describe 'Create action outpatient recipe' do
        before(:each) do
          visit '/'
          click_link 'Recetas'
          expect(page.has_link?('Ambulatorias')).to be true
          within '#new_patient' do
            expect(page.has_css?('input#patient-dni')).to be true
            page.execute_script %Q{$('#patient-dni').focus().val('37458994').keydown()}
            sleep 2
          end
          expect(find('ul.ui-autocomplete')).to have_content('37458994')
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
            find(:css, '#new-outpatient').click
            expect(page).to have_content('Agregar receta ambulatoria')
            expect(page).to have_content('37458994')
            expect(page.has_css?('input#professional')).to be true
            expect(page.has_css?('input#outpatient_prescription_date_prescribed')).to be true
            expect(page.has_css?('textarea#outpatient_prescription_observation')).to be true
            expect(page.has_css?('#order-product-cocoon-container')).to be true
            expect(page.has_field?('Código', type: 'text')).to be true
            expect(page.has_field?('Nombre', type: 'text')).to be true
            expect(page.has_css?('input#outpatient_prescription_outpatient_prescription_products_attributes_0_request_quantity')).to be true
            expect(page.has_css?('input#outpatient_prescription_outpatient_prescription_products_attributes_0_delivery_quantity')).to be true
            expect(page.has_link?('Agregar insumo')).to be true
            expect(page.has_button?('Guardar y dispensar')).to be true
          end

          describe 'save new outpatient recipe' do
            before(:each) do
              find("#{new_professional_path}")
              within '#professional-form-async' do
                page.execute_script %Q{$('#last-name').focus().val('Naval').keydown()}
                sleep 2
                within '#professionals-list' do
                  find(:css, '.btn-success').first.click
                end
                sleep 2
              end
            end
            it 'create recipe' do
              expect(oage.has_css?('#professional')).to be true
            end
          end
        end
      end
    end
  end
end