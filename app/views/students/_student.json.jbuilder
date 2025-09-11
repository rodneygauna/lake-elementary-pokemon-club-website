json.extract! student, :id, :first_name, :middle_name, :last_name, :suffix_name, :grade, :class_number, :teacher_name, :favorite_pokemon, :notes, :created_at, :updated_at
json.url student_url(student, format: :json)
