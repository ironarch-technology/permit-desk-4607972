class CreatePermitApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :permit_applications do |t|
      t.string :reference, null: false
      t.references :account, null: false, foreign_key: true
      t.references :parcel, foreign_key: true
      t.string :work_type, null: false
      t.text :scope_narrative
      t.bigint :valuation_cents, null: false, default: 0
      t.string :applicant_name
      t.string :applicant_email
      t.string :applicant_phone
      t.string :contractor_licence
      t.date :contractor_licence_expiry
      t.string :state, null: false, default: 'draft'
      t.string :submission_key
      t.datetime :submitted_at
      t.timestamps
    end
    add_index :permit_applications, :reference, unique: true
    add_index :permit_applications, :state
  end
end
