class CreateChronicPrescriptionComments < ActiveRecord::Migration[5.2]
  def change
    create_table :chronic_prescription_comments do |t|
      t.references :chronic_prescription, index: {name: :unique_chron_pres_on_out_pres_comments}
      t.references :user, index: true
      t.text :text

      t.timestamps
    end
  end
end
