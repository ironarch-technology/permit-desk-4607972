class CreateFeeQuotes < ActiveRecord::Migration[7.1]
  def change
    create_table :fee_quotes do |t|
      t.references :permit_application, null: false, foreign_key: true
      t.bigint :total_cents, null: false
      t.jsonb :breakdown, null: false, default: {}
      t.string :quote_reference, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
