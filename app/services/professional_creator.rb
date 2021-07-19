class ProfessionalCreator
  def initialize(param)
    @first_name = param[:first_name]
    @last_name = param[:last_name]
    @id = param[:id] || ''
  end

  def find_practitioner
    token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjVmNmUzODFlODdlMTcwZTEwOTZhNzc2ZCIsImFwcCI6eyJpZCI6IjVmNmUzNjM1M2ZiNDkyMDlkMDEzOWQ5ZSIsIm5vbWJyZSI6IlNJRkhBTyJ9LCJvcmdhbml6YWNpb24iOnsiaWQiOiI1OTM4MDE1M2RiOGU5MGZlNDYwMmVjMDIiLCJub21icmUiOiJTSUZIQU8ifSwicGVybWlzb3MiOlsidXNlci9Pcmdhbml6YXRpb24ucmVhZCIsInVzZXIvUHJhY3RpdGlvbmVyLnJlYWQiLCJ1c2VyL1BhdGllbnQucmVhZCJdLCJhY2NvdW50X2lkIjpudWxsLCJ0eXBlIjoiYXBwLXRva2VuIiwiaWF0IjoxNjAxMDU4ODQ2fQ.OoW0qT83sanFwcbp2VFr1C0HxG79fNVYrVwtFAyvR7w'
    url = 'https://fhir.andes.gob.ar/4_0_0/practitioner'
    @practitioners = RestClient::Request.execute( method: :get,
                                                  url: url,
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
        sex: sex, qualifications_attributes: enrollments }
    end
    @formated_practitioners.select { |prac| prac[:qualifications_attributes].present? }
  end
end