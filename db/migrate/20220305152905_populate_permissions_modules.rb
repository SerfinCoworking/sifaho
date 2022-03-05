class PopulatePermissionsModules < ActiveRecord::Migration[5.2]
  def change
    # User permissions
    permission_module = PermissionModule.create(name: 'Usuario')
    Permission.create(name: 'read_users', permission_module: permission_module)
    Permission.create(name: 'update_permissions', permission_module: permission_module)
  end
end
