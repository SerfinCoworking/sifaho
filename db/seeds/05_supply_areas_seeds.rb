require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'supply_areas.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start Supply Area import"
csv.each do |row|
  t = SupplyArea.new
  t.id = row['Id']
  t.name = row['Name']
  t.save
end
puts "End Supply Area import"