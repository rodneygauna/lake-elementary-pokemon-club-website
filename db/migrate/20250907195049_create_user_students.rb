class CreateUserStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :user_students do |t|
      # Foreign keys
      t.references :user, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true

      t.timestamps
    end

    # ---- Indexes ----
    add_index :user_students, [ :user_id, :student_id ], unique: true
  end
end
