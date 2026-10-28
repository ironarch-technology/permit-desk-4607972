class AddPaymentRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :permit_application, null: false, foreign_key: true
      t.string :capture_reference, null: false
      t.bigint :amount_cents, null: false
      t.string :status, null: false, default: 'pending'
      t.timestamps
    end
    add_index :payments, :capture_reference
  end
end
