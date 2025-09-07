class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      # Core details
      t.string :email_address, null: false
      t.string :password_digest, null: false

      # User demographics
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone_number

      # Role with default for enum
      t.string :role, null: false, default: "user" # enum: user, admin

      # User status with default for enum
      t.string :status, null: false, default: "active" # enum: active, inactive, suspended

      t.timestamps
    end

    # ---- Indexes ----
    add_index :users, :email_address, unique: true
    add_index :users, :role
    add_index :users, :status
    add_index :users, [ :status, :role ]
  end
end
