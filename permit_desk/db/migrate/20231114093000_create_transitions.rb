class CreateTransitions < ActiveRecord::Migration[7.1]
  def change
    create_table :transitions do |t|
      t.references :permit_application, null: false, foreign_key: true
      t.string :from_state
      t.string :to_state, null: false
      t.string :actor, null: false
      t.string :source_system
      t.text :reason
      t.timestamps
    end
    add_index :transitions, %i[permit_application_id created_at]
  end
end
