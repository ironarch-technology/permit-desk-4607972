class CreateAccountsAndParcels < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :name, null: false
      t.string :role, null: false, default: 'applicant'
      t.timestamps
    end
    add_index :accounts, :email, unique: true

    create_table :parcels do |t|
      t.string :address, null: false
      t.string :district, null: false
      t.string :zoning_code, null: false
      t.timestamps
    end
    add_index :parcels, :address, unique: true
  end
end
