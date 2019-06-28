class PatientSerializer < ActiveModel::Serializer
  attributes :id, :dni, :first_name, :last_name, :birthdate, :marital_status, :sex

  def birthdate
    if object.birthdate.present? 
      object.birthdate.strftime "%d/%m/%Y"
    end
  end
end
