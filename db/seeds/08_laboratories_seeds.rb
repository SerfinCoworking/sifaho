require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'laboratories.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start laboratories import"
csv.each do |row|
  t = Laboratory.new
  t.id = row['Id']
  t.cuit = row['Cuit']
  t.gln = row ['Gln']
  t.name = row['Name']
  t.save
end
puts "End laboratories import"