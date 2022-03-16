class PopulatePermissionsModules < ActiveRecord::Migration[5.2]
  def change
    # User permissions
    permission_module = PermissionModule.create(name: 'Usuario')
    Permission.create(name: 'read_users', permission_module: permission_module)
    Permission.create(name: 'update_permissions', permission_module: permission_module)

    # Outpatient permissions
    recipes_permission_module = PermissionModule.create(name: 'Recetas Ambulatorias')
    Permission.create(name: 'read_outpatient_recipes', permission_module: recipes_permission_module)
    Permission.create(name: 'create_outpatient_recipes', permission_module: recipes_permission_module)
    Permission.create(name: 'update_outpatient_recipes', permission_module: recipes_permission_module)
    Permission.create(name: 'dispense_outpatient_recipes', permission_module: recipes_permission_module)
    Permission.create(name: 'return_outpatient_recipes', permission_module: recipes_permission_module)
    Permission.create(name: 'destroy_outpatient_recipes', permission_module: recipes_permission_module)
  end
end
