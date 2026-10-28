module Types
  class ParcelType < BaseObject
    field :address, String, null: false
    field :district, String, null: false
    field :zoning_code, String, null: false
  end
end
