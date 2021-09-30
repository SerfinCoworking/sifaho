class ProfessionalCreator
  def initialize(param)
    @first_name = param[:first_name] || ''
    @last_name = param[:last_name] || ''
    @id = param[:id] || ''
  end

  def find_practitioner
    return [] if @first_name.empty? && @last_name.empty?

    token = ENV['ANDES_FHIR_TOKEN']
    url = "#{ENV['ANDES_FHIR_URL']}/practitioner"
    @practitioners = RestClient::Request.execute( method: :get,
                                                  url: url,
                                                  verify_ssl: false,
                                                  timeout: 30,
                                                    headers: {
                                                    'Authorization' => "Bearer #{token}",
                                                    params: { 'given': @first_name, 'family': @last_name }
                                                  }
                                                )

    @formated_practitioners = JSON.parse(@practitioners).map do |doc|
      first_name = doc['name'][0]['given'].join(' ')
      last_name = doc['name'][0]['family'].join(' ')
      dni_filtered = doc['identifier'].select { |identifier| identifier['system'] == 'http://www.renaper.gob.ar/dni' }
      dni = dni_filtered[0]['value']
      sex = doc['gender'] || 'indeterminate'
      enrollments_filtered = doc['qualification'].select { |qual| qual['identifier'].present? && qual['code'].present? }
      enrollments = []
      unless enrollments_filtered.empty?
        enrollments = enrollments_filtered.map do |qual|
          { name: qual['identifier'][0]['value'], code: qual['code']['text'] }
        end
      end

      { id: @id, first_name: first_name, last_name: last_name, fullname: "#{last_name} #{first_name}", dni: dni,
        sex: sex, qualifications_attributes: enrollments, is_active: true }
    end
    @formated_practitioners.select { |prac| prac[:qualifications_attributes].present? }
  end
end