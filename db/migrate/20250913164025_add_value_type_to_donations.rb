class AddValueTypeToDonations < ActiveRecord::Migration[8.0]
  def change
    add_column :donations, :value_type, :string, null: false, default: 'monetary'
    add_index :donations, :value_type
  end
end
