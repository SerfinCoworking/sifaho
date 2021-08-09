class AddThemeToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :theme, :integer, default: 0
  end
end
