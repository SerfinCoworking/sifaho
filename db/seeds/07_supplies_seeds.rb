require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'supplies.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start supplies import"
csv.each do |row|
  t = Supply.new
  t.id = row['Id']
  t.name = row['Name']
  t.description = row['Description']
  t.unity = row['Unity']
  t.supply_area_id = row['supply_area_id']
  t.created_at = row['Created at']
  t.updated_at = row['Updated at']
  t.save
end
puts "End supplies import"