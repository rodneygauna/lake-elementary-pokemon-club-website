class CreateSeasons < ActiveRecord::Migration[8.0]
  def change
    create_table :seasons do |t|
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, default: "active", null: false

      t.timestamps
    end

    add_index :seasons, :name, unique: true
    add_index :seasons, :status
    add_index :seasons, [ :start_date, :end_date ]
  end
end
