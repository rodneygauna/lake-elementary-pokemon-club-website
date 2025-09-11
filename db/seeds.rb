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
puts "Password: password123"
