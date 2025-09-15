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
  },
  {
    email: "jessica.volunteer@email.com",
    first_name: "Jessica",
    last_name: "Miller",
    role: "super_user"
  },
  {
    email: "david.helper@email.com",
    first_name: "David",
    last_name: "Clark",
    role: "super_user"
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
  },
  {
    first_name: "Zoe",
    last_name: "Thompson",
    grade: "kindergarten_grade",
    age: 5,
    favorite_pokemon: "Togepi",
    parent_emails: [ "sarah.johnson@email.com" ],
    status: "active"
  },
  {
    first_name: "Caleb",
    last_name: "Rodriguez",
    grade: "sixth_grade",
    age: 12,
    favorite_pokemon: "Blaziken",
    parent_emails: [ "mike.smith@email.com" ],
    status: "active"
  },
  {
    first_name: "Maya",
    last_name: "Chen",
    grade: "third_grade",
    age: 8,
    favorite_pokemon: "Vulpix",
    parent_emails: [ "emily.davis@email.com" ],
    status: "active"
  },
  {
    first_name: "Jake",
    last_name: "Williams",
    grade: "fourth_grade",
    age: 9,
    favorite_pokemon: "Machamp",
    parent_emails: [ "robert.wilson@email.com" ],
    status: "inactive"
  },
  {
    first_name: "Grace",
    last_name: "Taylor",
    grade: "first_grade",
    age: 6,
    favorite_pokemon: "Clefairy",
    parent_emails: [ "jennifer.brown@email.com" ],
    status: "active"
  },
  {
    first_name: "Aiden",
    last_name: "Lee",
    grade: "fifth_grade",
    age: 11,
    favorite_pokemon: "Dragonite",
    parent_emails: [ "david.garcia@email.com" ],
    status: "inactive"
  },
  {
    first_name: "Chloe",
    last_name: "Walker",
    grade: "second_grade",
    age: 7,
    favorite_pokemon: "Skitty",
    parent_emails: [ "lisa.martinez@email.com" ],
    status: "active"
  },
  {
    first_name: "Tyler",
    last_name: "Hall",
    grade: "sixth_grade",
    age: 12,
    favorite_pokemon: "Scyther",
    parent_emails: [ "james.anderson@email.com" ],
    status: "inactive"
  },
  {
    first_name: "Lily",
    last_name: "White",
    grade: "kindergarten_grade",
    age: 5,
    favorite_pokemon: "Ditto",
    parent_emails: [ "sarah.johnson@email.com" ],
    status: "active"
  },
  {
    first_name: "Connor",
    last_name: "Green",
    grade: "third_grade",
    age: 8,
    favorite_pokemon: "Alakazam",
    parent_emails: [ "mike.smith@email.com" ],
    status: "active"
  },
  {
    first_name: "Mia",
    last_name: "Adams",
    grade: "fourth_grade",
    age: 9,
    favorite_pokemon: "Rapidash",
    parent_emails: [ "emily.davis@email.com" ],
    status: "inactive"
  },
  {
    first_name: "Ryan",
    last_name: "Clark",
    grade: "first_grade",
    age: 6,
    favorite_pokemon: "Magikarp",
    parent_emails: [ "robert.wilson@email.com" ],
    status: "active"
  }
]

students = students_data.map do |student_data|
  Student.find_or_create_by!(
    first_name: student_data[:first_name],
    last_name: student_data[:last_name]
  ) do |student|
    student.grade = student_data[:grade]
    student.favorite_pokemon = student_data[:favorite_pokemon]
    student_status = student_data[:status] || "active"
    student.status = student_status

    if student_status == "active"
      student.notes = "Active member of the Pokemon Club. Age: #{student_data[:age]} years old."
    else
      student.notes = "Former member of the Pokemon Club. Age: #{student_data[:age]} years old. Status changed to inactive."
    end
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

# Create donors and donations
puts "Creating donors and donations..."

# First, create donors (without donation details)
donors_data = [
  {
    name: "Smith Family",
    donor_type: "individual",
    privacy_setting: "public",
    website_link: nil,
    created_by: admin_user
  },
  {
    name: "Johnson & Associates Law Firm",
    donor_type: "business",
    privacy_setting: "public",
    website_link: "https://johnsonlaw.example.com",
    created_by: admin_user
  },
  {
    name: "Local Pokemon Store",
    donor_type: "business",
    privacy_setting: "public",
    website_link: "https://pokemonstore.example.com",
    created_by: admin_user
  },
  {
    name: "Garcia Family",
    donor_type: "individual",
    privacy_setting: "anonymous",
    website_link: nil,
    created_by: admin_user
  },
  {
    name: "Lake Elementary PTA",
    donor_type: "business",
    privacy_setting: "public",
    website_link: nil,
    created_by: admin_user
  },
  {
    name: "Anderson Family",
    donor_type: "individual",
    privacy_setting: "public",
    website_link: nil,
    created_by: admin_user
  },
  {
    name: "TechCorp Solutions",
    donor_type: "business",
    privacy_setting: "public",
    website_link: "https://techcorp.example.com",
    created_by: admin_user
  },
  {
    name: "Wilson Family",
    donor_type: "individual",
    privacy_setting: "private",
    website_link: nil,
    created_by: admin_user
  },
  {
    name: "Community Bank of Lakewood",
    donor_type: "business",
    privacy_setting: "public",
    website_link: "https://communitybankoflakewood.example.com",
    created_by: admin_user
  },
  {
    name: "Brown Family",
    donor_type: "individual",
    privacy_setting: "anonymous",
    website_link: nil,
    created_by: admin_user
  }
]

# Create donors
donors = donors_data.map do |donor_data|
  Donor.find_or_create_by!(name: donor_data[:name]) do |donor|
    donor.donor_type = donor_data[:donor_type]
    donor.privacy_setting = donor_data[:privacy_setting]
    donor.website_link = donor_data[:website_link]
    donor.user = donor_data[:created_by]
  end
end

puts "Created #{donors.count} donors"

# Now create donations for each donor
puts "Creating donations..."

donations_data = [
  # Smith Family donations - mixed types
  { donor_name: "Smith Family", amount: 100.00, donation_type: "Cash Donation", value_type: "monetary", donation_date: Date.current - 30.days, notes: "Thank you for supporting our club!" },
  { donor_name: "Smith Family", amount: nil, donation_type: "Homemade Snacks", value_type: "material", donation_date: Date.current - 10.days, notes: "Cookies and juice boxes for meeting" },

  # Johnson & Associates donations - monetary
  { donor_name: "Johnson & Associates Law Firm", amount: 500.00, donation_type: "Annual Sponsorship", value_type: "monetary", donation_date: Date.current - 45.days, notes: "Annual club sponsorship" },

  # Local Pokemon Store donations - materials
  { donor_name: "Local Pokemon Store", amount: nil, donation_type: "Pokemon Trading Cards", value_type: "material", donation_date: Date.current - 20.days, notes: "Starter decks and booster packs" },
  { donor_name: "Local Pokemon Store", amount: nil, donation_type: "Gaming Supplies", value_type: "material", donation_date: Date.current - 5.days, notes: "Deck protectors and play mats" },

  # Garcia Family donations - monetary
  { donor_name: "Garcia Family", amount: 75.00, donation_type: "Cash Donation", value_type: "monetary", donation_date: Date.current - 25.days, notes: "Anonymous donation" },  # PTA donations
  { donor_name: "Lake Elementary PTA", amount: 300.00, donation_type: "Tournament Funding", value_type: "monetary", donation_date: Date.current - 60.days, notes: "Funding for Pokemon tournament" },
  { donor_name: "Lake Elementary PTA", amount: nil, donation_type: "Meeting Refreshments", value_type: "material", donation_date: Date.current - 15.days, notes: "Snacks and beverages for meetings" },

  # Anderson Family donations - materials
  { donor_name: "Anderson Family", amount: nil, donation_type: "Meeting Snacks", value_type: "material", donation_date: Date.current - 12.days, notes: "Homemade cookies and juice" },

  # TechCorp donations - services and monetary
  { donor_name: "TechCorp Solutions", amount: nil, donation_type: "IT Support Services", value_type: "service", donation_date: Date.current - 90.days, notes: "Setting up digital gaming stations" },
  { donor_name: "TechCorp Solutions", amount: 300.00, donation_type: "Software Licenses", value_type: "monetary", donation_date: Date.current - 30.days, notes: "Pokemon game app subscriptions" },

  # Wilson Family donations - materials
  { donor_name: "Wilson Family", amount: nil, donation_type: "Art & Craft Supplies", value_type: "material", donation_date: Date.current - 8.days, notes: "Colored pencils, markers, and construction paper" },

  # Community Bank donations - monetary
  { donor_name: "Community Bank of Lakewood", amount: 750.00, donation_type: "Prize Sponsorship", value_type: "monetary", donation_date: Date.current - 40.days, notes: "Gift cards and trophies for tournament winners" },

  # Brown Family donations - materials
  { donor_name: "Brown Family", amount: nil, donation_type: "Movie Night Treats", value_type: "material", donation_date: Date.current - 18.days, notes: "Popcorn and drinks for Pokemon movie night" }
]

# Create donations
created_donations = 0
donations_data.each do |donation_data|
  donor = donors.find { |d| d.name == donation_data[:donor_name] }
  if donor
    Donation.find_or_create_by!(
      donor: donor,
      amount: donation_data[:amount],
      donation_date: donation_data[:donation_date]
    ) do |donation|
      donation.donation_type = donation_data[:donation_type]
      donation.value_type = donation_data[:value_type]
      donation.notes = donation_data[:notes]
    end
    created_donations += 1
  end
end

puts "Created #{created_donations} donations"

puts "\n=== SEED DATA SUMMARY ==="
puts "👑 Admin User: admin@pokemonclub.test (password: password123)"
puts "� Super Users: #{User.where(role: 'super_user').count} (all with password: password123)"
puts "�👨‍👩‍👧‍👦 Parent Users: #{User.where(role: 'user').count} (all with password: password123)"
puts "🎓 Students: #{Student.count}"
puts "🔗 User-Student Links: #{UserStudent.count}"
puts "📅 Events: #{Event.count}"
puts "💝 Donors: #{Donor.count}"
puts "   - Individual Donors: #{Donor.where(donor_type: 'individual').count}"
puts "   - Business Donors: #{Donor.where(donor_type: 'business').count}"
puts "   - Public Donors: #{Donor.where(privacy_setting: 'public').count}"
puts "   - Anonymous Donors: #{Donor.where(privacy_setting: 'anonymous').count}"
puts "   - Private Donors: #{Donor.where(privacy_setting: 'private').count}"
puts "💖 Donations: #{Donation.count}"
puts "   - Monetary Donations: #{Donation.where(value_type: 'monetary').count}"
puts "   - Material Donations: #{Donation.where(value_type: 'material').count}"
puts "   - Service Donations: #{Donation.where(value_type: 'service').count}"
puts "   - Total Money Amount: $#{Donation.where(value_type: 'monetary').sum(:amount).to_f.round(2)}"
monetary_donations = Donation.where(value_type: 'monetary')
if monetary_donations.count > 0
  puts "   - Average Monetary Donation: $#{(monetary_donations.sum(:amount) / monetary_donations.count).to_f.round(2)}"
end
# Create sample documents
puts "Creating sample documents..."

sample_documents = [
  {
    title: "Club Handbook",
    description: "Complete guide to Pokemon Club rules, activities, and expectations for students and parents.",
    document_type: "link",
    url: "https://example.com/pokemon-club-handbook"
  },
  {
    title: "Meeting Schedule",
    description: "Current semester meeting dates and special events calendar.",
    document_type: "link",
    url: "https://example.com/meeting-schedule"
  },
  {
    title: "Permission Slip",
    description: "Required permission form for all club activities and field trips.",
    document_type: "link",
    url: "https://forms.google.com/pokemon-club-permission"
  },
  {
    title: "Pokemon Care Guide",
    description: "Educational resource about Pokemon types, abilities, and care tips for young trainers.",
    document_type: "link",
    url: "https://pokemon.com/us/pokemon-care-guide"
  },
  {
    title: "Contact Information",
    description: "Emergency contacts and club leadership information for parents and guardians.",
    document_type: "link",
    url: "https://example.com/contact-info"
  },
  {
    title: "Club Rules",
    description: "Behavior expectations and safety guidelines for all club members.",
    document_type: "link",
    url: "https://example.com/club-rules"
  }
]

sample_documents.each do |doc_data|
  document = Document.find_or_create_by!(title: doc_data[:title]) do |doc|
    doc.description = doc_data[:description]
    doc.document_type = doc_data[:document_type]
    doc.url = doc_data[:url] if doc_data[:url]
    doc.created_by = admin_user
  end
  puts "   ✓ #{document.title} (#{document.document_type})"
end

puts "\n📄 Documents: #{Document.count}"
puts "   - Link Documents: #{Document.where(document_type: 'link').count}"
puts "   - File Documents: #{Document.where(document_type: 'file').count}"

# Create default email subscriptions for all users
puts "\nCreating default email subscriptions..."
all_users = User.all
subscription_count = 0

all_users.each do |user|
  puts "   Setting up subscriptions for #{user.first_name} #{user.last_name}..."
  user.create_default_subscriptions!
  subscription_count += user.email_subscriptions.count
end

puts "\n📧 Email Subscriptions: #{EmailSubscription.count}"
puts "   - Total Users with Subscriptions: #{User.joins(:email_subscriptions).distinct.count}"
puts "   - Enabled Subscriptions: #{EmailSubscription.enabled.count}"
puts "   - Disabled Subscriptions: #{EmailSubscription.disabled.count}"

puts "\nAll users can log in with their email and password 'password123'"
puts "==========================="
