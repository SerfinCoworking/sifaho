require 'csv'

csv_text2 = File.read(Rails.root.join('lib', 'seeds', 'products.csv'))
csv = CSV.parse(csv_text2, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start Products import"
csv.each do |row|
  t = Product.new
  t.code = row['Id']
  t.name = row['Name']
  t.description = row['Description']
  t.observation = row['Observation']
  t.unity = row['Unity']
  t.created_at = row['Created at']
  t.updated_at = row['Updated at']
  t.save!(validate: false)
end
puts "End Products import"