require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'sectors.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start sectors import"
csv.each do |row|
  t = Sector.new
  t.id = row['Id']
  t.name = row['Name']
  t.description = row['Description']
  t.establishment_id = row['establishment_id']
  t.save
end
puts "End sectors import"