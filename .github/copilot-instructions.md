# Lake Elementary Pokémon Club Website - AI Coding Instructions

## Project Overview

This is a Rails 8 web application for managing a school Pokémon club. It serves as a centralized digital hub addressing three core problems: communication gaps between club leadership and parents, donor recognition, and resource accessibility. The application handles user management, student registration, event scheduling, donor recognition, document management, and provides admin controls for a K-6 elementary school environment.

## Business Context

- **Primary Goal**: Improve communication about club meetings (e.g., first meeting Sept 17, Sept 24 cancelled)
- **Secondary Goals**: Showcase community donors, centralize club resources and documents
- **Target Users**: Parents/guardians, school staff, community members, club administrators
- **Security Focus**: School-safe environment with admin-only user account creation

## Core Architecture & Patterns

### Authentication System

- Uses Rails 8's built-in authentication with `has_secure_password`
- **Critical**: Only admins can create user accounts (security requirement for school environment)
- Authentication handled via `Authentication` concern in `app/controllers/concerns/`
- Session management through `Current` model using `ActiveSupport::CurrentAttributes`
- Cookie-based sessions with `find_session_by_cookie` pattern

### Data Model Relationships

```ruby
User (parents/staff)
├─ has_many :user_students (join table)
├─ has_many :students, through: :user_students
└─ has_many :sessions

Student (club members)
├─ has_many :user_students
└─ has_many :users, through: :user_students

Event (club meetings/activities)
├─ Time zone aware with UTC storage
└─ Status enum: draft|published|canceled
```

### Model Conventions

All models follow this consistent structure:

1. **Enums** (string-backed for DB readability)
2. **Validations**
3. **Associations**
4. **Normalizations** (email downcasing, etc.)
5. **Callbacks**
6. **Scopes** (ordered by: time-based, status-based, search)
7. **Instance Methods**

Example enum pattern: `enum :status, { active: "active", inactive: "inactive" }`

### Controller Structure

- `ApplicationController` includes `Authentication` concern
- Use `allow_unauthenticated_access` for public endpoints
- Admin namespace for user management: `admin/users_controller.rb`
- Nested resources: `students/:id/user_students` for parent-student linking

## Development Workflow

### Setup & Running

```bash
bin/setup          # Initial setup (installs deps, prepares DB)
bin/dev            # Start development server (Rails server)
bundle install     # Install Ruby gems
yarn install       # Install JS dependencies
bin/rails db:prepare # Setup database
```

### Code Quality

- Uses `rubocop-rails-omakase` for Ruby styling
- Available linting: `bin/rubocop`
- Security scanning: `bin/brakeman`
- Modern browser requirements enforced via `allow_browser versions: :modern`

### Database

- SQLite for development/test/production (per PRD requirements)
- Uses Solid Cache, Solid Queue, Solid Cable (Rails 8 defaults)
- Migration pattern: `bin/rails generate migration`
- Seeding: Use `db/seeds.rb` for initial admin user and sample data

## Key Business Logic

### User Roles & Permissions

- **admin**: Full access, can manage users and all resources
- **user**: Limited to their own profile and linked students
- Grade levels: K-6 (kindergarten through sixth grade)

### Time Handling

Events are timezone-aware:

- Store in UTC, display in `time_zone` field
- Scopes: `upcoming`, `past`, `starting_soon`, `overlapping`
- Calendar functionality with timezone conversion

### Student-Parent Relationships

- Many-to-many through `user_students` join table
- Parents can be linked to multiple students
- Students can have multiple parent/guardian accounts

## Deployment & Infrastructure

- Dockerized with `Dockerfile` and `config.ru`
- Kamal deployment configuration in `config/deploy.yml`
- Puma web server with Thruster for performance
- PWA capabilities (commented routes available)
- Target: Heroku or similar Rails-compatible platform with SQLite support
- HTTPS enforcement required for production (school security)

## Testing & Security

- Test files in `test/` directory following Rails conventions
- Brakeman for security analysis
- CSRF protection and secure password handling
- Modern browser security headers

## Donor Management System

### Donor Types & Features

- **Individual Donors**: Name, donation amount/type, optional photo upload
- **Business Donors**: Company name, logo upload, contribution details, website link
- **Privacy Controls**: Donor visibility preferences in admin interface
- **Recognition**: Automated display on public donor wall with carousel for business logos

### Donor Model Requirements

- Support for both individual and business donors
- Donation tracking with amounts and types
- Photo/logo upload using Active Storage
- Privacy settings for donor visibility preferences
- Public donor recognition page with carousel display

## Future Models & Features (Per PRD)

Planned models to implement using Rails scaffolding:

- **Donor**: Individual/business donors with Active Storage for photos/logos
- **Document**: File repository with categorization and access control
- **EmailSubscription**: Granular notification preferences for users

## Scaffolding Conventions

Follow Rails 8 scaffolding for rapid CRUD development:

```bash
rails generate scaffold Donor name:string donor_type:string amount:decimal privacy_setting:string
rails generate scaffold Document title:string description:text category:string
```

## Design Implementation Requirements

### Before Creating Any View

1. **Review `docs/DESIGN-GUIDE.md`** - Follow ALL established patterns
2. **Apply Blue Text Rule** - Verify no blue text except hyperlinks
3. **Use Standard Page Structure** - Breadcrumbs → Actions → Header Card → Content
4. **Include Required Components**:
   - Breadcrumb navigation with proper links
   - Header card with `bg-primary` and white text
   - Action buttons positioned before header
   - Confirmation modal for delete actions (`<%= render "shared/generic_confirmation_modal" %>`)
   - Proper responsive grid layout

### Component Checklist

- [ ] Font Awesome icons with proper spacing (`me-1`, `me-2`)
- [ ] Semantic color usage (no blue text for non-links)
- [ ] Card-based layout with `shadow-sm` styling
- [ ] Proper form validation styling
- [ ] Mobile-responsive design
- [ ] Toggle switches for binary filters (show/hide inactive, cancelled, etc.)
- [ ] Admin/user permission checks where needed
- [ ] Delete buttons in action area (never in card bodies)
- [ ] Status badges only for exceptional states (not defaults like "published" or "active")
- [ ] Action buttons grouped together with consistent spacing (`me-2`)

## UI/UX Requirements & Design System

### **CRITICAL DESIGN RULE** ⭐

- **Blue Text Rule**: Blue text (`text-primary`) ONLY for hyperlinks and clickable elements
- **All other text must use semantic colors:**
  - `text-dark` - Regular content, headings, data values
  - `text-muted` - Secondary information, helper text, labels
  - `text-warning` - Pokémon-related content (theme appropriate)
  - `text-success` - Success states, active statuses
  - `text-danger` - Error states, danger actions

### Design System Standards

- **Pokemon Theme**: Electric Blue (#0084FF) primary, Pikachu Yellow (#FFD700) accents
- **Bootstrap 5**: Responsive design with accessibility focus (WCAG 2.2 AA)
- **Mobile-First**: All interfaces must work on mobile devices
- **Clean Design**: Minimal, family-friendly interface suitable for parents
- **Card-Based Layout**: Consistent structure across all pages
- **Font Awesome Icons**: Consistent iconography throughout application

### Standard Page Structure (MANDATORY)

1. **Breadcrumb Navigation** - Clear hierarchy with `text-decoration-none` links
2. **Action Buttons** - Back, Edit, Delete buttons grouped together before header (never isolate delete buttons)
3. **Header Card** - Blue background (`bg-primary`) with white text, icon + title
4. **Content Cards** - Shadow-sm styling, proper spacing (`shadow-sm mb-4`)
5. **Confirmation Modals** - For all destructive actions

### Component Patterns

- **Information Cards**: Light gray backgrounds (#f8f9fa), proper typography hierarchy
- **Form Sections**: Headers with `text-dark border-bottom pb-2 mb-3`
- **Status Badges**: Only show for exceptional states (cancelled, draft, inactive) - NOT for normal states (published, active)
- **Data Tables**: Gradient blue headers, alternating row colors
- **Empty States**: Centered with large icons, contextual messaging
- **Filter Toggles**: Use `form-check form-switch` for binary filters (show/hide inactive, cancelled, etc.) with auto-submit on change
- **Action Button Grouping**: All action buttons (Back, Edit, Delete) must be grouped together before header card - never isolate delete buttons in card bodies

### Reference Documentation

- **Complete Design Guide**: `docs/DESIGN-GUIDE.md` - MUST follow all patterns documented here
- **All new pages and components MUST conform to established design patterns**

## Email System Architecture

- **Action Mailer**: Notification system for events, cancellations, updates
- **Background Jobs**: Use Rails 8 default queue adapter for async email sending
- **Templates**: ERB templates with both text and HTML versions
- **Subscription Management**: Granular control over notification types

## File Management Strategy

- **Active Storage**: Local storage adapter for development and production
- **File Types**: PDFs (forms, documents), images (PNG/JPG for donor logos)
- **Security**: Access control for sensitive documents vs public resources
- **Categories**: Forms, Meeting Notes, Pokemon Resources, General Information

## Important File Locations

- **Design Guide**: `docs/DESIGN-GUIDE.md` - **CRITICAL**: Complete UI/UX patterns and standards
- Authentication logic: `app/controllers/concerns/authentication.rb`
- User model patterns: `app/models/user.rb` (reference for enum/scope structure)
- Routes with admin namespace: `config/routes.rb`
- Time zone handling: `app/models/event.rb`
- Development scripts: `bin/` directory
- Project requirements: `docs/PRD.md` (comprehensive technical and business specs)
- Generic confirmation modal: `app/views/shared/_generic_confirmation_modal.html.erb`
- Design system CSS: `app/assets/stylesheets/application.css` (Pokemon theme colors)
