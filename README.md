# Lake Elementary Pokémon Club Website

A Rails 8 web application for managing a school Pokémon club, serving as a centralized digital hub for communication, donor recognition, and resource accessibility.

## Quick Start

```bash
# Clone and setup
git clone [repository-url]
cd lake-elementary-pokemon-club-website

# Install dependencies and setup database
bin/setup

# Start development server
bin/dev
```

## Development

### Key Commands

- `bin/dev` - Start development server
- `bin/rails console` - Rails console
- `bin/rails db:migrate` - Run database migrations
- `bin/rails db:seed` - Seed database with sample data
- `bin/rubocop` - Run linting
- `bin/brakeman` - Security analysis

### Technology Stack

- **Framework**: Rails 8 with SQLite
- **Authentication**: Built-in Rails authentication
- **Styling**: Bootstrap 5 with Pokémon theme
- **Icons**: Font Awesome
- **Background Jobs**: Solid Queue (Rails 8 default)

## Documentation

- **[Product Requirements Document](docs/PRD.md)** - Complete technical and business specifications
- **[Design Guide](docs/DESIGN-GUIDE.md)** - UI/UX patterns, components, and styling standards ⭐
- **[Bylaws](docs/BYLAWS.md)** - Club governance and rules
- **[AI Coding Instructions](.github/copilot-instructions.md)** - Development guidelines for AI assistance

## Project Structure

### Key Models

- **User**: Parents/guardians and admin staff
- **Student**: Club members with grade levels K-6
- **Event**: Club meetings and activities
- **UserStudent**: Many-to-many relationship between users and students

### Authentication & Authorization

- Cookie-based sessions with `has_secure_password`
- **Admin-only account creation** (school security requirement)
- Role-based access: `admin` and `user` roles

## Design System

The application follows a consistent design system documented in [docs/DESIGN-GUIDE.md](docs/DESIGN-GUIDE.md):

- **Pokémon Theme**: Electric Blue (#0084FF) and Pikachu Yellow (#FFD700)
- **Blue Text Rule**: Blue text only for hyperlinks
- **Card-based Layout**: Consistent structure across all pages
- **Responsive Design**: Mobile-first with Bootstrap 5

## Deployment

- **Docker**: Configured with Dockerfile and docker-compose
- **Kamal**: Deployment configuration in `config/deploy.yml`
- **Target Platforms**: Heroku or similar Rails-compatible hosting

## Contributing

1. Follow the established design patterns in [docs/DESIGN-GUIDE.md](docs/DESIGN-GUIDE.md)
2. Run `bin/rubocop` before committing
3. Ensure all tests pass
4. Update documentation for new features

## License

[Add your license information here]
