class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      # Core details
      t.string   :title,     null: false
      t.text     :description
      t.datetime :starts_at, null: false
      t.datetime :ends_at,   null: false

      # Time zone with default
      t.string   :time_zone, null: false, default: "America/Los_Angeles"

      # Address fields
      t.string :venue
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zipcode

      # Status with default for enum
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    # ---- Indexes ----
    add_index :events, :starts_at
    add_index :events, :ends_at
    add_index :events, :status
    add_index :events, :time_zone
    add_index :events, :zipcode
    add_index :events, [ :status, :starts_at ]
  end
end
