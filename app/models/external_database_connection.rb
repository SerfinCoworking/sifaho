class ExternalDatabaseConnection < ActiveRecord::Base
  establish_connection(:db2)

  self.table_name = "patient"
end
