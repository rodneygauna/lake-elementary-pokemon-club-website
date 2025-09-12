# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user
puts "Creating admin user..."
admin_user = User.find_or_create_by!(email_address: "admin@pokemonclub.test") do |user|
  user.first_name = "Club"
  user.last_name = "Administrator"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "admin"
  user.status = "active"
end

puts "Admin user created with email: #{admin_user.email_address}"

# Create regular users (parents/guardians)
puts "Creating parent/guardian users..."

parent_users_data = [
  {
    email: "sarah.johnson@email.com",
    first_name: "Sarah",
    last_name: "Johnson",
    role: "user"
  },
  {
    email: "mike.smith@email.com",
    first_name: "Mike",
    last_name: "Smith",
    role: "user"
  },
  {
    email: "emily.davis@email.com",
    first_name: "Emily",
    last_name: "Davis",
    role: "user"
  },
  {
    email: "robert.wilson@email.com",
    first_name: "Robert",
    last_name: "Wilson",
    role: "user"
  },
  {
    email: "jennifer.brown@email.com",
    first_name: "Jennifer",
    last_name: "Brown",
    role: "user"
  },
  {
    email: "david.garcia@email.com",
    first_name: "David",
    last_name: "Garcia",
    role: "user"
  },
  {
    email: "lisa.martinez@email.com",
    first_name: "Lisa",
    last_name: "Martinez",
    role: "user"
  },
  {
    email: "james.anderson@email.com",
    first_name: "James",
    last_name: "Anderson",
    role: "user"
  }
]

parent_users = parent_users_data.map do |user_data|
  User.find_or_create_by!(email_address: user_data[:email]) do |user|
    user.first_name = user_data[:first_name]
    user.last_name = user_data[:last_name]
    user.password = "password123"
    user.password_confirmation = "password123"
    user.role = user_data[:role]
    user.status = "active"
  end
end

puts "Created #{parent_users.count} parent/guardian users"

# Create students
puts "Creating students..."

students_data = [
  {
    first_name: "Alex",
    last_name: "Johnson",
    grade: "third_grade",
    age: 8,
    favorite_pokemon: "Pikachu",
    parent_emails: [ "sarah.johnson@email.com" ]
  },
  {
    first_name: "Emma",
    last_name: "Johnson",
    grade: "fifth_grade",
    age: 10,
    favorite_pokemon: "Eevee",
    parent_emails: [ "sarah.johnson@email.com" ]
  },
  {
    first_name: "Liam",
    last_name: "Smith",
    grade: "fourth_grade",
    age: 9,
    favorite_pokemon: "Charizard",
    parent_emails: [ "mike.smith@email.com" ]
  },
  {
    first_name: "Sophia",
    last_name: "Davis",
    grade: "second_grade",
    age: 7,
    favorite_pokemon: "Jigglypuff",
    parent_emails: [ "emily.davis@email.com" ]
  },
  {
    first_name: "Noah",
    last_name: "Wilson",
    grade: "fifth_grade",
    age: 11,
    favorite_pokemon: "Lucario",
    parent_emails: [ "robert.wilson@email.com" ]
  },
  {
    first_name: "Olivia",
    last_name: "Brown",
    grade: "third_grade",
    age: 8,
    favorite_pokemon: "Sylveon",
    parent_emails: [ "jennifer.brown@email.com" ]
  },
  {
    first_name: "Mason",
    last_name: "Garcia",
    grade: "fourth_grade",
    age: 9,
    favorite_pokemon: "Greninja",
    parent_emails: [ "david.garcia@email.com" ]
  },
  {
    first_name: "Isabella",
    last_name: "Martinez",
    grade: "first_grade",
    age: 6,
    favorite_pokemon: "Mew",
    parent_emails: [ "lisa.martinez@email.com" ]
  },
  {
    first_name: "Ethan",
    last_name: "Anderson",
    grade: "fifth_grade",
    age: 10,
    favorite_pokemon: "Rayquaza",
    parent_emails: [ "james.anderson@email.com" ]
  },
  {
    first_name: "Ava",
    last_name: "Anderson",
    grade: "third_grade",
    age: 8,
    favorite_pokemon: "Gardevoir",
    parent_emails: [ "james.anderson@email.com" ]
  },
  {
    first_name: "Lucas",
    last_name: "Smith-Davis",
    grade: "second_grade",
    age: 7,
    favorite_pokemon: "Squirtle",
    parent_emails: [ "mike.smith@email.com", "emily.davis@email.com" ]
  }
]

students = students_data.map do |student_data|
  Student.find_or_create_by!(
    first_name: student_data[:first_name],
    last_name: student_data[:last_name]
  ) do |student|
    student.grade = student_data[:grade]
    student.favorite_pokemon = student_data[:favorite_pokemon]
    student.notes = "Active member of the Pokemon Club. Age: #{student_data[:age]} years old."
    student.status = "active"
  end
end

puts "Created #{students.count} students"

# Create relationships between users and students
puts "Creating user-student relationships..."

students_data.each do |student_data|
  student = Student.find_by(
    first_name: student_data[:first_name],
    last_name: student_data[:last_name]
  )

  student_data[:parent_emails].each do |parent_email|
    parent = User.find_by(email_address: parent_email)
    if parent && student
      UserStudent.find_or_create_by!(user: parent, student: student)
      puts "  - Linked #{parent.first_name} #{parent.last_name} to #{student.first_name} #{student.last_name}"
    end
  end
end

# Create events
puts "Creating events..."

events_data = [
  {
    title: "Weekly Pokemon Club Meeting",
    description: "Join us for our regular weekly meeting! We'll have trading card battles, discussions about the latest Pokemon episodes, and fun activities for all trainers.",
    starts_at: 1.day.from_now.change(hour: 15, min: 30),
    ends_at: 1.day.from_now.change(hour: 17, min: 0),
    venue: "Lake Elementary School - Room 205",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "published",
    special: false
  },
  {
    title: "Pokemon Trading Card Tournament",
    description: "Monthly tournament for all skill levels! Bring your best deck and compete for amazing prizes. Beginners welcome - we'll help you learn!",
    starts_at: 1.week.from_now.change(hour: 10, min: 0),
    ends_at: 1.week.from_now.change(hour: 14, min: 0),
    venue: "Lake Elementary School - Gymnasium",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "published",
    special: true
  },
  {
    title: "Pokemon Movie Night",
    description: "Come watch Pokemon: The Rise of Darkrai with fellow trainers! Popcorn and drinks provided. Don't forget to bring your favorite Pokemon plushie!",
    starts_at: 2.weeks.from_now.change(hour: 18, min: 0),
    ends_at: 2.weeks.from_now.change(hour: 20, min: 30),
    venue: "Lake Elementary School - Auditorium",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "published",
    special: true
  },
  {
    title: "Pokemon Art & Craft Workshop",
    description: "Create your own Pokemon artwork! We'll be making Pokeball crafts, drawing our favorite Pokemon, and creating custom trainer badges.",
    starts_at: 3.weeks.from_now.change(hour: 14, min: 0),
    ends_at: 3.weeks.from_now.change(hour: 16, min: 0),
    venue: "Lake Elementary School - Art Room",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "published",
    special: false
  },
  {
    title: "Beginner's Pokemon Card Workshop",
    description: "New to Pokemon cards? This workshop is perfect for you! Learn the basics of the game, deck building, and get a free starter deck to take home.",
    starts_at: 1.month.from_now.change(hour: 15, min: 0),
    ends_at: 1.month.from_now.change(hour: 17, min: 0),
    venue: "Lake Elementary School - Library",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "published",
    special: false
  },
  {
    title: "Pokemon Trivia Challenge",
    description: "Test your Pokemon knowledge in our ultimate trivia challenge! Teams of 3-4 trainers will compete across multiple categories. Prizes for top teams!",
    starts_at: 5.weeks.from_now.change(hour: 16, min: 0),
    ends_at: 5.weeks.from_now.change(hour: 18, min: 0),
    venue: "Lake Elementary School - Cafeteria",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "published",
    special: true
  },
  {
    title: "Show and Tell: My Favorite Pokemon",
    description: "Bring your favorite Pokemon card, toy, or drawing to share with the club! Everyone gets a participation sticker and we'll vote on some fun categories.",
    starts_at: 6.weeks.from_now.change(hour: 15, min: 30),
    ends_at: 6.weeks.from_now.change(hour: 16, min: 30),
    venue: "Lake Elementary School - Room 205",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "published",
    special: false
  },
  {
    title: "End of Semester Pokemon Party",
    description: "Celebrate the end of our semester with games, prizes, snacks, and a special surprise guest! All club members and their families are invited.",
    starts_at: 2.months.from_now.change(hour: 17, min: 0),
    ends_at: 2.months.from_now.change(hour: 19, min: 0),
    venue: "Lake Elementary School - Gymnasium",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "published",
    special: true
  },
  {
    title: "DRAFT: Planning Next Month's Activities",
    description: "Internal planning meeting for club coordinators to discuss upcoming activities and events. This is a draft event to test admin visibility.",
    starts_at: 3.days.from_now.change(hour: 19, min: 0),
    ends_at: 3.days.from_now.change(hour: 20, min: 0),
    venue: "Staff Room",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "draft",
    special: false
  },
  {
    title: "CANCELLED: Outdoor Pokemon Hunt",
    description: "Unfortunately cancelled due to weather concerns. We'll reschedule for a better day!",
    starts_at: 4.days.from_now.change(hour: 14, min: 0),
    ends_at: 4.days.from_now.change(hour: 16, min: 0),
    venue: "School Playground",
    address1: "123 Elementary Lane",
    city: "Lakewood",
    state: "CA",
    zipcode: "90210",
    time_zone: "America/Los_Angeles",
    status: "canceled",
    special: true
  }
]

events = events_data.map do |event_data|
  Event.find_or_create_by!(title: event_data[:title]) do |event|
    event.description = event_data[:description]
    event.starts_at = event_data[:starts_at]
    event.ends_at = event_data[:ends_at]
    event.venue = event_data[:venue]
    event.address1 = event_data[:address1]
    event.city = event_data[:city]
    event.state = event_data[:state]
    event.zipcode = event_data[:zipcode]
    event.time_zone = event_data[:time_zone]
    event.status = event_data[:status]
    event.special = event_data[:special]
  end
end

puts "Created #{events.count} events"

puts "\n=== SEED DATA SUMMARY ==="
puts "👑 Admin User: admin@pokemonclub.test (password: password123)"
puts "👨‍👩‍👧‍👦 Parent Users: #{User.where(role: 'user').count} (all with password: password123)"
puts "🎓 Students: #{Student.count}"
puts "🔗 User-Student Links: #{UserStudent.count}"
puts "📅 Events: #{Event.count}"
puts "\nAll users can log in with their email and password 'password123'"
puts "==========================="
