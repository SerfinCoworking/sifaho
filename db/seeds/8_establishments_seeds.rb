require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'establishments.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start establishments import"
csv.each do |row|
  t = Establishment.new
  t.id = row['Id']
  t.name = row['Name']
  t.cuit = row['Cuit']
  t.domicile = row['Domicile']
  t.phone = row['Phone']
  t.email = row['Email']
  t.sectors_count = row['Sectors count']
  t.save
end
puts "End establishments import"