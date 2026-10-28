ADDRESSES = [
  ['114 Harbor Reach', 'North Shore', 'R-1'],
  ['2290 Calder Street', 'Calder Flats', 'R-2'],
  ['8 Kestrel Lane', 'North Shore', 'R-1'],
  ['517 Dockside Avenue', 'Harbor District', 'C-2'],
  ['1430 Monteith Road', 'Westfield', 'R-3'],
  ['77 Fairweather Court', 'Westfield', 'R-1'],
  ['3002 Lamplight Way', 'Calder Flats', 'R-2'],
  ['640 Quarry Bend', 'Quarry Hill', 'I-1']
].freeze

ADDRESSES.each do |address, district, zoning_code|
  Parcel.find_or_create_by!(address: address) do |parcel|
    parcel.district = district
    parcel.zoning_code = zoning_code
  end
end

Account.find_or_create_by!(email: 'rosa.linden@example.com') do |account|
  account.name = 'Rosa Linden'
  account.password = 'harborlight'
  account.role = 'applicant'
end

Account.find_or_create_by!(email: 'dmitri.vale@example.com') do |account|
  account.name = 'Dmitri Vale'
  account.password = 'harborlight'
  account.role = 'applicant'
end

Account.find_or_create_by!(email: 'counter@mountport.gov') do |account|
  account.name = 'Mountport Permit Counter'
  account.password = 'frontdesk'
  account.role = 'technician'
end

puts "seeded #{Parcel.count} parcels and #{Account.count} accounts"
