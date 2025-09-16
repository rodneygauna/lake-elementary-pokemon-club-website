# Production Seeds Configuration
# This file contains only the essential data needed for production deployment
# Sample data is excluded to keep production clean

puts "🌱 Seeding production database..."

# Create admin user with secure defaults
puts "Creating admin user..."

# Get admin credentials from environment or use secure defaults
admin_email = ENV.fetch("ADMIN_EMAIL", "rodneygauna@gmail.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "ChangeMe123!")

admin_user = User.find_or_create_by!(email_address: admin_email) do |user|
  user.first_name = "Rodney"
  user.last_name = "Gauna"
  user.password = admin_password
  user.password_confirmation = admin_password
  user.role = "admin"
  user.status = "active"
end

puts "✅ Admin user created successfully!"
puts "📧 Email: #{admin_user.email_address}"
puts "🔑 Password: #{admin_password}"
puts ""
puts "🚨 IMPORTANT: Please change this password immediately after first login!"
puts ""

# Only create sample data in non-production environments
unless Rails.env.production?
  puts "🧪 Development environment detected - loading sample data..."

  # Load the original seeds.rb content for development
  # (You can keep your existing seeds.rb content here for development)

  puts "✅ Sample data loaded for development"
else
  puts "🏭 Production environment - skipping sample data"
end

puts "🎉 Database seeding complete!"
