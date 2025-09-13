class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.references :event, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.references :marked_by, null: false, foreign_key: { to_table: :users }
      t.boolean :present, default: false, null: false
      t.datetime :marked_at

      t.timestamps
    end

    # Ensure unique attendance record per event-student combination
    add_index :attendances, [ :event_id, :student_id ], unique: true
  end
end
