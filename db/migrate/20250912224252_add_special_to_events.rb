class AddSpecialToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :special, :boolean, default: false, null: false
  end
end
