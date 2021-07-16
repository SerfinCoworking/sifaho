class CreateQualifications < ActiveRecord::Migration[5.2]
  def change
    create_table :qualifications do |t|
      t.references :professional, index: true
      t.string :name
      t.string :code

      t.timestamps
    end

    Professional.all.each do |professional|
      Qualification.create(professional_id: professional.id, name: 'MEDICO', code: professional.enrollment)
    end
  end
end
