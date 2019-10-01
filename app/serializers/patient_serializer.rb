class PatientSerializer < ActiveModel::Serializer
  attributes :id, :dni, :cuil, :andes_id, :last_name, :first_name,  :birthdate, :marital_status, :sex

  def birthdate
    if object.birthdate.present? 
      object.birthdate.strftime "%d/%m/%Y"
    end
  end
end
