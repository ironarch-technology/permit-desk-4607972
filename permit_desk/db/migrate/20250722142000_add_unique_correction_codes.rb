class AddUniqueCorrectionCodes < ActiveRecord::Migration[7.1]
  def change
    add_index :correction_items, %i[permit_application_id cycle code], unique: true,
              name: 'index_correction_items_on_application_cycle_code'
  end
end
