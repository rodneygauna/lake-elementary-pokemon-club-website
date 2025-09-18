# Product Requirements Document (PRD)

## Lake Elementary School Pokemon Club Website

**Project Name:** Lake Elementary Pokemon Club Website
**Version:** 2.2
**Date:** September 18, 2025
**Author:** Rodney Gauna
**Status:** Development Phase - Financial Management System Added

---

## 1. Executive Summary

The Lake Elementary School Pokemon Club website will serve as a centralized digital hub for club communication, donor recognition, financial management, and resource management. Built as a Ruby on Rails 8 web application, the site will address critical communication gaps between club leadership and parents while showcasing community support, providing transparent financial reporting, and offering easy access to important club resources. The application features a secure user authentication system with admin-managed accounts, comprehensive content management capabilities, complete donor and donation management system, robust financial tracking with expense allocation, email notifications, and robust data management through Active Record and Active Storage. Enhanced security measures ensure that only authorized administrators can create user accounts, providing better control and safety for the school environment.

---

## 2. Problem Statement

The Pokemon Club at Lake Elementary School currently faces three primary challenges:

### 2.1 Communication Gap

- **Problem:** Parents lack timely information about club meetings and events
- **Impact:** Confusion about meeting schedules, missed events, poor attendance
- **Example:** Parents need to know that the first meeting is September 17, but September 24 is cancelled

### 2.2 Donor Recognition

- **Problem:** No centralized way to acknowledge and showcase community donors
- **Impact:** Missed opportunities for donor appreciation and future fundraising
- **Need:** Platform to highlight both individual and business contributors

### 2.3 Resource Accessibility

- **Problem:** Important documents and links are scattered across different platforms
- **Impact:** Difficulty accessing meeting notes, permission forms, Pokemon resources, and reference materials
- **Users Affected:** Parents, club members, and club leadership

### 2.4 Financial Management & Transparency

- **Problem:** No system to track club expenses, fund allocation, or financial transparency
- **Impact:** Difficulty reporting how donations and registration fees are utilized, lack of financial accountability
- **Example:** Parents pay $15 registration fees and businesses donate $100, but there's no way to show how $60 spent on crayons was allocated from these fund sources
- **Users Affected:** Club administrators managing finances, parents wanting transparency on fund usage

---

## 3. Solution Overview

### 3.1 Approach

A **Ruby on Rails 8 web application** featuring:

- **Rails 8 Authentication** for user management and access control
- **Active Record** for robust data modeling and relationships
- **Active Storage** for file uploads and document management
- **Rails Scaffolding** for rapid CRUD interface development
- **Action Mailer** for email notifications and subscriptions
- **Bootstrap 5** for responsive, accessible styling
- **Cloud hosting** (Heroku or similar) for reliable deployment

### 3.2 Why This Approach?

- **Rapid Development:** Rails scaffolding and conventions for quick feature implementation
- **User Management:** Built-in authentication with role-based access control
- **Data Integrity:** Active Record validations and database constraints
- **File Management:** Active Storage for seamless document handling
- **Email Integration:** Action Mailer for automated notifications
- **Financial Management:** Complete fund tracking and expense allocation system
- **Scalability:** Full-stack framework supporting future feature expansion
- **Maintainability:** Convention over configuration reduces complexity

---

## 4. Target Users

### 4.1 Primary Users

- **Parents/Guardians:** Need meeting schedules, event information, club resources, and account access
- **School Staff:** Information about club activities and schedules with potential admin access
- **Community Members:** Public viewing of club activities and donor recognition

### 4.2 Secondary Users

- **Potential Donors:** Viewing impact of previous donations and recognition
- **Students:** Linked to parent accounts for relationship tracking (no direct access)

### 4.3 Administrative Users

- **Club Leader (Administrator):** Full CRUD access to all content, exclusive user management and account creation
- **Assistant Leaders (Super User):** Admin interface access, content management, attendance tracking, but no delete permissions
- **School Staff (Administrator):** Information about club activities and schedules with potential admin access
- **Future Contributors:** Additional staff or volunteers with guided admin or super user access and user management permissions

### 4.4 User Account Management

- **Security Model:** Admin-only user account creation for enhanced security
- **Account Creation:** Administrators create accounts for parents/guardians with temporary passwords
- **User Onboarding:** New users receive secure temporary credentials and must update their profile
- **Profile Management:** Users can self-manage names, email, and password (role changes admin-only)

---

## 5. Functional Requirements

### 5.1 User Authentication & Authorization

- **REQ-1.1:** Secure user authentication system using Rails 8 authentication (admin-managed accounts only)
- **REQ-1.2:** Role-based access control (Administrator, Super User, vs Normal User)
- **REQ-1.3:** Administrator users have full CRUD access to all resources including user management
- **REQ-1.4:** Super User role has admin interface access but restricted delete permissions for volunteer safety
- **REQ-1.5:** Normal users have read-only access to public content
- **REQ-1.5:** Password reset functionality via email
- **REQ-1.6:** User profile management for account information
- **REQ-1.7:** Enhanced security model with admin-only user creation and temporary password assignment
- **REQ-1.8:** Three-tier role system with granular permissions (user < super_user < admin)

### 5.2 Student Management

- **REQ-2.1:** Student model with relationship to parent/guardian users
- **REQ-2.2:** Parents can view and manage their linked students
- **REQ-2.3:** Administrators can create and manage all student relationships
- **REQ-2.4:** Student information includes name, grade, and relevant club details

### 5.3 Meeting & Event Management

- **REQ-3.1:** CRUD interface for meeting and event management (scaffolded)
- **REQ-3.2:** Display upcoming meeting dates, times, and descriptions
- **REQ-3.3:** Show cancelled or rescheduled meetings prominently
- **REQ-3.4:** Event categorization and status tracking
- **REQ-3.5:** Calendar view for easy schedule overview

### 5.4 Donor Recognition System

- **REQ-4.1:** CRUD interface for donor management (scaffolded)
- **REQ-4.2:** Support for individual and business donors
- **REQ-4.3:** Donation tracking with amounts and types
- **REQ-4.4:** Photo/logo upload using Active Storage
- **REQ-4.5:** Public donor recognition page with carousel display
- **REQ-4.6:** Privacy settings for donor visibility preferences

### 5.5 Event Attendance Tracking System

- **REQ-5.1:** Admin-level attendance tracking interface on event show pages (admin and super_user roles)
- **REQ-5.2:** Toggle-based attendance marking for all active students
- **REQ-5.3:** Attendance model with event-student-admin relationships
- **REQ-5.4:** Visual feedback for attendance status (color-coded toggle buttons)
- **REQ-5.5:** Attendance tracking available for all events regardless of status or timing
- **REQ-5.6:** Attendance audit trail with timestamp and admin-level user tracking

### 5.6 Document Repository

- **REQ-6.1:** CRUD interface for document management (scaffolded)
- **REQ-6.2:** File upload functionality using Active Storage
- **REQ-6.3:** Document categorization (forms, meeting notes, resources)
- **REQ-6.4:** Access control for sensitive documents
- **REQ-6.5:** Download tracking and basic analytics

### 5.7 Email Notification System

- **REQ-7.1:** General notifications (new events, cancellations, donations, news)
- **REQ-7.2:** Email templates for consistent branding
- **REQ-7.3:** Automated notifications for content changes

### 5.8 Financial Management System

- **REQ-8.1:** CRUD interface for fund source management (scaffolded)
- **REQ-8.2:** Support for multiple fund source types (registration fees, PTA funding, business donations, individual donations)
- **REQ-8.3:** CRUD interface for expense tracking with receipt attachment via Active Storage
- **REQ-8.4:** Free-text expense categorization with vendor notation capability
- **REQ-8.5:** Fund allocation system allowing manual allocation of multiple fund sources to expenses
- **REQ-8.6:** Split expense functionality across multiple fund sources with tracking
- **REQ-8.7:** Privacy controls for fund sources and expenses (public/private visibility)
- **REQ-8.8:** Financial dashboard with fund balances and allocation summaries
- **REQ-8.9:** Reporting system with monthly, quarterly, and annual filtering
- **REQ-8.10:** Public transparency dashboard respecting privacy settings
- **REQ-8.11:** Admin-only access to financial management (super users and regular users excluded)
- **REQ-8.12:** Integration with existing donor system for donation fund sources

### 5.9 Navigation & User Experience

- **REQ-9.1:** Responsive design using Bootstrap 5 and Rails view helpers
- **REQ-9.2:** Consistent navigation with user authentication status
- **REQ-9.3:** User profile and content access for authenticated users
- **REQ-9.4:** Admin interface for content management
- **REQ-9.5:** Fast loading times with Rails optimization techniques

---

## 6. Non-Functional Requirements

### 6.1 Security

- **REQ-10.1:** Secure user authentication with encrypted passwords
- **REQ-10.2:** Protection against common web vulnerabilities (CSRF, XSS, SQL injection)
- **REQ-10.3:** Role-based authorization enforcement
- **REQ-10.4:** Secure file upload validation and storage
- **REQ-10.5:** HTTPS enforcement in production

### 6.2 Accessibility

- **REQ-11.1:** WCAG 2.2 AA compliance
- **REQ-11.2:** Keyboard navigation support
- **REQ-11.3:** Screen reader compatibility
- **REQ-11.4:** Sufficient color contrast ratios
- **REQ-11.5:** Alternative text for all images and documents

### 6.3 Performance

- **REQ-12.1:** Page load time under 3 seconds
- **REQ-12.2:** Database query optimization
- **REQ-12.3:** Efficient file serving via Active Storage
- **REQ-12.4:** Caching implementation for static content

### 6.4 Compatibility

- **REQ-13.1:** Support modern browsers (Chrome, Firefox, Safari, Edge)
- **REQ-13.2:** Mobile responsiveness across devices
- **REQ-13.3:** Progressive enhancement for feature support

### 6.5 Maintenance & Deployment

- **REQ-14.1:** Simple deployment via Git-based hosting (Heroku/similar)
- **REQ-14.2:** Database migrations for schema management
- **REQ-14.3:** Environment-based configuration management
- **REQ-14.4:** Automated testing capabilities
- **REQ-14.5:** Regular security updates and dependency management

---

## 7. Technical Architecture

### 7.1 Technology Stack

- **Backend Framework:** Ruby on Rails 8
- **Database:** SQLite3 (development and production)
- **Authentication:** Rails 8 built-in authentication system
- **File Storage:** Active Storage with local storage adapter
- **Frontend:** HTML5, ERB templates, CSS3 (Bootstrap 5), JavaScript (Stimulus)
- **Email:** Action Mailer with Rails built-in SMTP delivery
- **Hosting:** Heroku or similar Rails-compatible platform
- **Version Control:** Git with GitHub repository
- **Package Management:** Bundler for Ruby gems
- **Asset Pipeline:** Rails asset pipeline with importmap

### 7.2 Data Models

#### Core Models

- **User:** Authentication, roles (admin/normal), email preferences
- **Student:** Name, grade, belongs_to user (parent/guardian)
- **Event:** Title, description, date, status, category, created_by admin
- **Attendance:** Event-student attendance tracking with admin audit trail
- **Donor:** Name, donor_type (individual/business), contact info, privacy settings, photo attachment
- **Donation:** Normalized donation tracking with value_type (monetary/material/service), amounts, descriptions
- **Document:** Title, description, category, file attachment via Active Storage
- **FundSource:** Fund tracking with source_type (registration|pta_funding|business_donation|individual_donation), amount, description, privacy settings
- **Expense:** Club expense tracking with category, vendor, amount, description, receipt attachment, privacy settings
- **FundAllocation:** Many-to-many allocation tracking linking fund sources to expenses with allocated amounts

#### Relationships

- User has_many students through user_students (many-to-many)
- Event belongs_to user (creator)
- Event has_many attendances (one-to-many)
- Student has_many attendances (one-to-many)
- Attendance belongs_to event, student, and marked_by (user/admin)
- Donor has_many donations (one-to-many)
- Donation belongs_to donor
- Donor has_one_attached photo (Active Storage)
- Document belongs_to user (creator)
- Document has_one_attached file
- FundSource has_many fund_allocations (one-to-many)
- FundSource belongs_to donor (optional, for donation-based fund sources)
- Expense has_many fund_allocations (one-to-many)
- Expense belongs_to user (creator)
- Expense has_one_attached receipt (Active Storage)
- FundAllocation belongs_to fund_source and expense (many-to-many join)

### 7.3 Rails Application Structure

```text
├── Gemfile                     # Ruby gem dependencies
├── Gemfile.lock               # Gem version lock file
├── config.ru                 # Rack configuration
├── Rakefile                   # Rake tasks
├── README.md                  # Project documentation
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── events_controller.rb      # Generated scaffold
│   │   ├── home_controller.rb        # Public homepage
│   │   ├── students_controller.rb    # Student management
│   │   ├── users_controller.rb       # User profile management
│   │   ├── admin/
│   │   │   ├── users_controller.rb   # Admin user management
│   │   │   ├── donors_controller.rb  # Donor management (admin)
│   │   │   ├── donations_controller.rb # Donation management (nested)
│   │   │   ├── fund_sources_controller.rb # Fund source management (admin)
│   │   │   ├── expenses_controller.rb # Expense management (admin)
│   │   │   └── fund_allocations_controller.rb # Fund allocation management (admin)
│   │   ├── documents_controller.rb   # Document management
│   │   └── financial_transparency_controller.rb # Public financial transparency
│   ├── models/
│   │   ├── application_record.rb
│   │   ├── user.rb
│   │   ├── student.rb
│   │   ├── user_student.rb           # Join table for many-to-many
│   │   ├── event.rb
│   │   ├── attendance.rb             # Event-student attendance tracking
│   │   ├── donor.rb                  # Individual/business donors
│   │   ├── donation.rb               # Normalized donation tracking
│   │   ├── fund_source.rb            # Fund source tracking with privacy controls
│   │   ├── expense.rb                # Club expense tracking with receipt attachment
│   │   ├── fund_allocation.rb        # Fund source to expense allocation tracking
│   │   └── document.rb               # File repository
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application.html.erb
│   │   ├── events/                   # Event management views
│   │   ├── home/                     # Public homepage
│   │   ├── students/                 # Student management views
│   │   ├── users/                    # User profile views
│   │   ├── admin/
│   │   │   ├── users/                # Admin user management
│   │   │   ├── donors/               # Admin donor management
│   │   │   ├── donations/            # Admin donation management
│   │   │   ├── fund_sources/         # Admin fund source management
│   │   │   ├── expenses/             # Admin expense management
│   │   │   └── fund_allocations/     # Admin fund allocation management
│   │   ├── shared/                   # Reusable components
│   │   ├── documents/                # Document views
│   │   └── financial_transparency/   # Public financial transparency views
│   ├── mailers/
│   │   ├── application_mailer.rb
│   │   └── notification_mailer.rb
│   ├── jobs/
│   │   └── email_notification_job.rb
│   └── assets/
│       ├── stylesheets/
│       │   └── application.css       # Pokemon-themed styles
│       └── javascripts/
│           └── application.js
├── config/
│   ├── application.rb
│   ├── database.yml
│   ├── routes.rb
│   ├── credentials.yml.enc
│   └── environments/
│       ├── development.rb
│       ├── production.rb
│       └── test.rb
├── db/
│   ├── migrate/                      # Database migrations
│   ├── schema.rb
│   └── seeds.rb
├── test/                            # Rails test suite
├── storage/                         # Active Storage files (development)
└── docs/
    └── PRD.md
```

### 7.4 Development Workflow

- **Setup:** `rails new pokemon_club` (uses SQLite3 by default)
- **Scaffolding:** `rails generate scaffold Event title:string description:text date:datetime status:string`
- **Development:** `rails server` for local development
- **Database:** `rails db:migrate` and `rails db:seed` for schema management
- **Testing:** `rails test` for automated testing
- **Deployment:** Git-based deployment to Heroku or similar platform (with SQLite3 compatibility)

### 7.5 Authentication & Authorization

- **Authentication:** Rails 8 built-in authentication with encrypted passwords
- **Sessions:** Rails session management with secure cookies
- **Authorization:** Role-based access control in controllers and views
- **Middleware:** Custom middleware for admin-only sections
- **Password Security:** bcrypt encryption with secure defaults

### 7.6 Email System Architecture

- **Mailer Classes:** Notification mailer for event updates, cancellations using Action Mailer
- **Background Jobs:** Asynchronous email sending using Active Job with Rails built-in queue adapter
- **Templates:** ERB email templates with text and HTML versions
- **Delivery:** Rails built-in SMTP delivery method configured in environment settings
- **Configuration:** SMTP settings in `config/environments/` files for development and production

### 7.7 File Management

- **Active Storage:** Rails built-in file attachment system
- **Storage Adapters:** Local storage for both development and production
- **File Types:** PDF documents, images (PNG, JPG), with validation
- **Security:** Secure file serving with access control
- **Processing:** Image variants for donor logos and profile pictures

---

## 8. User Interface Design

### 8.1 Design Principles

- **Clean & Modern:** Minimal design with clear typography
- **Pokemon Branding:** Subtle Pokemon-themed color palette and elements
- **Accessibility First:** High contrast, clear navigation, readable fonts
- **Mobile-Responsive:** Seamless experience across all devices

### 8.2 Color Palette (Pokemon-Inspired)

- **Primary:** Electric Blue (#0084FF) - reminiscent of Pokemon blue
- **Secondary:** Pikachu Yellow (#FFD700) - accent color
- **Success:** Grass Green (#28A745) - for positive actions
- **Neutral:** Clean grays and whites for readability

### 8.3 Key Pages

1. **Home:** Welcome message, quick links, upcoming events
2. **Schedule:** Meeting calendar and event details
3. **Donors:** Recognition wall with photos/logos
4. **Resources:** Document repository with categories
5. **Financial Transparency:** Public financial dashboard with fund balances and expense summaries
6. **About:** Club information and contact details

---

## 9. Content Strategy

### 9.1 Event Management

- **Format:** Database-driven with web forms for CRUD operations
- **Update Frequency:** Real-time updates through admin interface
- **Content Types:** Regular meetings, special events, cancellations, announcements
- **Workflow:** Administrators create/edit events, users receive email notifications

### 9.2 User Account Management Workflow

- **Account Creation:** Administrators create user accounts via secure admin interface (`/admin/users`)
- **Credential Distribution:** System generates temporary passwords, administrators share securely with parents
- **User Onboarding:** Parents log in with temporary credentials and update their profile information
- **Profile Management:** Users access self-service profile management at `/user` for name, email, and password updates
- **Security:** Role changes and account deletions restricted to administrators only
- **Administrative Controls:** Comprehensive user management with safety features (admins cannot delete themselves)

### 9.3 Donor Management

- **Individual Donors:** Name, donation amount/type, optional photo upload
- **Business Donors:** Company name, logo upload, contribution details, website link
- **Privacy Controls:** Donor visibility preferences in admin interface
- **Recognition:** Automated display on public donor wall with carousel for business logos

### 9.4 Financial Management Workflow

- **Fund Source Tracking:** Administrators create fund source records for registration fees, PTA funding, and donations
- **Expense Recording:** Real-time expense entry through admin interface with receipt upload capability
- **Allocation Process:** Manual allocation of fund sources to expenses with split capability across multiple sources
- **Privacy Management:** Admin-controlled visibility settings for sensitive financial information
- **Transparency Dashboard:** Public financial summary respecting privacy settings for donor confidence
- **Integration:** Automatic fund source creation for monetary donations through existing donor system
- **Reporting:** Monthly, quarterly, and annual financial reports with filtering and export capabilities

### 9.5 Document Organization

- **Categories:** Forms, Meeting Notes, Pokemon Resources, General Information
- **Metadata:** Auto-generated (title, upload date, file type) and manual (description, category)
- **Access Control:** Public documents vs. authenticated user documents
- **File Management:** Active Storage with local file storage

### 9.6 User Communication

- **Email Templates:** Professional templates for notifications, reminders, updates
- **Notification Types:** Event notifications, donor updates, general announcements
- **Personalization:** Addressed to user's name, relevant student information

---

## 10. Success Metrics

### 10.1 User Engagement

- **Target:** 90% of admin-created parent accounts actively accessing schedule information monthly
- **Measure:** User login frequency analytics and profile completion rates

### 10.2 Communication Effectiveness

- **Target:** Reduce meeting attendance confusion by 80%
- **Measure:** Parent feedback surveys and meeting attendance consistency
- **Email Metrics:** Open rates, click-through rates for email notifications

### 10.3 Resource Utilization

- **Target:** 75% of club families accessing document repository through authenticated accounts
- **Measure:** Document download statistics and user engagement metrics

### 10.4 Administrative Efficiency

- **Target:** Reduce content update time by 60% compared to manual processes
- **Measure:** Time tracking for content creation and updates through admin interface

### 10.5 Financial Transparency & Accountability

- **Target:** 90% of parents express confidence in club financial management through quarterly surveys
- **Measure:** Parent feedback surveys, financial transparency page engagement metrics
- **Administrative Metrics:** Complete expense allocation within 30 days of purchase, 100% receipt documentation

### 10.6 Technical Performance

- **Target:** 99% uptime, <3 second load times, secure user data management
- **Measure:** Application monitoring, database performance metrics, security audit results

---

## 11. Risk Assessment

### 11.1 Technical Risks

- **Risk:** Database performance issues with file uploads and user growth
- **Mitigation:** Implement database indexing, use cloud storage for files, monitor performance metrics

### 11.2 Security Risks

- **Risk:** User data breaches or unauthorized access to sensitive information
- **Mitigation:** Follow Rails security best practices, regular security updates, role-based access control

### 11.3 Content Management Risks

- **Risk:** Administrators accidentally deleting important content or breaking functionality
- **Mitigation:** Implement soft deletes, regular database backups, admin training documentation

### 11.4 Email Delivery Risks

- **Risk:** Email notifications not being delivered due to SMTP configuration issues
- **Mitigation:** Test email delivery in development environment, configure proper SMTP settings, implement email delivery monitoring

### 11.5 Financial Management Risks

- **Risk:** Misallocation of funds or inaccurate financial reporting leading to donor mistrust
- **Mitigation:** Implement allocation validation rules, regular financial audits, clear approval workflows
- **Risk:** Unauthorized access to sensitive financial information
- **Mitigation:** Admin-only access controls, audit trails for all financial transactions, secure receipt storage

### 11.6 Hosting and Deployment Risks

- **Risk:** Application downtime during deployments or hosting platform issues
- **Mitigation:** Use zero-downtime deployment strategies, choose reliable hosting provider, implement monitoring alerts

---

## 12. Future Considerations

### 12.1 Potential Enhancements

- **Interactive Features:** RSVP functionality for events, online permission slip submissions
- **Advanced Communication:** SMS notifications, push notifications, in-app messaging
- **Enhanced User Experience:** User dashboards, personalized content recommendations
- **Reporting & Analytics:** Attendance tracking, engagement reports, donation analytics
- **Financial Analytics:** Advanced financial reporting, budget forecasting, donor impact analysis
- **Mobile App:** Native mobile application using Rails API backend
- **Integration:** School district systems integration, calendar application sync

### 12.2 Scalability Considerations

- **Database Optimization:** Query optimization, database sharding for larger user bases
- **Caching Strategy:** Redis integration for session management and content caching
- **CDN Integration:** Content delivery network for static assets and file downloads
- **Microservices:** Potential separation of email service into independent microservice

### 12.3 Technical Evolution

- **API Development:** RESTful API for future mobile app or third-party integrations
- **Real-time Features:** Action Cable implementation for live notifications
- **Advanced Authentication:** Two-factor authentication, social login integration
- **Backup & Recovery:** Automated backup systems and disaster recovery procedures

---

*This PRD serves as the foundation for the Lake Elementary Pokemon Club Ruby on Rails web application development and should be updated as requirements evolve during the implementation process.*
