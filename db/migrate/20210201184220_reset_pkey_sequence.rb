class ResetPkeySequence < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end
end
