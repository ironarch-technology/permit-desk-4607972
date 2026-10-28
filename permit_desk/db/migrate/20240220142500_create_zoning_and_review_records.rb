class CreateZoningAndReviewRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :zoning_checks do |t|
      t.references :permit_application, null: false, foreign_key: true
      t.string :handle, null: false
      t.string :result
      t.text :detail
      t.datetime :settled_at
      t.timestamps
    end
    add_index :zoning_checks, :handle

    create_table :correction_items do |t|
      t.references :permit_application, null: false, foreign_key: true
      t.integer :cycle, null: false, default: 1
      t.string :code, null: false
      t.text :narrative
      t.string :citation
      t.timestamps
    end

    create_table :correction_responses do |t|
      t.references :correction_item, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
  end
end
