class EnableDatabaseExtensions < ActiveRecord::Migration[5.2]
  def change
    enable_extension "fuzzystrmatch"
    enable_extension "unaccent"
    enable_extension "pg_trgm"
  end
end
