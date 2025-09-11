class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      # Student demographics
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix_name

      # School details
      t.string :grade
      t.string :class_number
      t.string :teacher_name

      # Additional info
      t.string :favorite_pokemon
      t.text :notes

      # Student status with default for enum
      t.string :status, null: false, default: "active" # enum: active, inactive

      t.timestamps
    end

    # ---- Indexes ----
    add_index :students, :last_name
    add_index :students, :grade
    add_index :students, :status
    add_index :students, [ :last_name, :grade ]
    add_index :students, [ :status, :grade ]
  end
end
