# Lake Elementary Pokémon Club Website - Design Guide

## Overview

This guide documents the design paradigms, patterns, and standards established for the Pokémon Club website to ensure consistency across all pages and components.

## Core Design Principles

### 1. **Blue Text Rule** ⭐ **CRITICAL**

- **Blue text (`text-primary`) ONLY for hyperlinks and clickable elements**
- **All other text uses semantic colors:**
  - `text-dark` - Regular content, headings, data values
  - `text-muted` - Secondary information, helper text, labels
  - `text-warning` - Pokémon-related content (theme appropriate)
  - `text-success` - Success states, active statuses
  - `text-danger` - Error states, danger actions

### 2. **Pokémon Theme Colors**

- **Primary Blue**: `#0084FF` (Electric Blue)
- **Secondary Yellow**: `#FFD700` (Pikachu Yellow)
- **Light Blue**: `var(--pokemon-light-blue)` - For backgrounds
- **Light Yellow**: `var(--pokemon-light-yellow)` - For backgrounds
- **CSS Custom Properties** defined in `app/assets/stylesheets/application.css`

## Page Structure Pattern

### Standard Page Layout

**IMPORTANT**: The application layout (`app/views/layouts/application.html.erb`) already provides a `container` wrapper around all page content. Individual pages should NOT add additional container divs or unnecessary row/column wrappers.

```erb
<% content_for :title, "Page Title" %>

<!-- 1. BREADCRUMB NAVIGATION -->
<nav aria-label="breadcrumb" class="mb-3">
  <ol class="breadcrumb">
    <li class="breadcrumb-item">
      <%= link_to "Parent Page", parent_path, class: "text-decoration-none" %>
    </li>
    <li class="breadcrumb-item active" aria-current="page">Current Page</li>
  </ol>
</nav>

<!-- 2. ACTION BUTTONS (Before Header) -->
<div class="d-flex justify-content-between align-items-center mb-4">
  <div>
    <%= link_to back_path, class: "btn btn-outline-secondary me-2" do %>
      <i class="fas fa-arrow-left me-1"></i>Back
    <% end %>
    <%= link_to edit_path, class: "btn btn-outline-primary me-2" do %>
      <i class="fas fa-edit me-1"></i>Edit
    <% end %>
    <!-- Delete button (admin only) -->
    <% if admin? %>
      <%= form_with model: @record, method: :delete, local: true, class: "d-inline", id: "delete-record-form" do |form| %>
        <button type="button"
                class="btn btn-outline-danger"
                data-bs-toggle="modal"
                data-bs-target="#confirmationModal"
                data-confirm-title="Delete Record"
                data-confirm-message="Are you sure you want to delete this record?"
                data-confirm-action="Delete Record"
                data-form-id="delete-record-form">
          <i class="fas fa-trash me-1"></i>Delete
        </button>
      <% end %>
    <% end %>
  </div>
</div>

<!-- 3. HEADER CARD -->
<div class="card shadow-sm mb-4">
  <div class="card-header bg-primary text-white">
    <div class="d-flex align-items-center justify-content-between">
      <div class="d-flex align-items-center">
        <i class="fas fa-icon me-2"></i>
        <h1 class="h4 mb-0">Page Title</h1>
      </div>
      <div class="d-flex align-items-center">
        <!-- Badges, counters, quick actions -->
      </div>
    </div>
  </div>
  <div class="card-body">
    <p class="text-muted mb-0">
      <i class="fas fa-info-circle me-1"></i>
      Descriptive text about the page functionality.
    </p>
  </div>
</div>

<!-- 4. MAIN CONTENT CARDS -->
<div class="card shadow-sm">
  <div class="card-body">
    <!-- Page content here -->
  </div>
</div>
```

## Component Patterns

### 1. **Information Cards**

```erb
<div class="card shadow-sm">
  <div class="card-body">
    <h5 class="text-dark border-bottom pb-2 mb-4">
      <i class="fas fa-info-circle me-2"></i>Section Title
    </h5>

    <div class="row g-3">
      <div class="col-12 col-md-6">
        <div class="p-3 rounded" style="background-color: #f8f9fa;">
          <h6 class="text-muted mb-1">
            <i class="fas fa-icon me-1"></i>Field Label
          </h6>
          <div class="fw-bold text-dark">
            Field Value
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
```

### 2. **Statistics Dashboard**

```erb
<div class="card shadow-sm mb-4">
  <div class="card-body">
    <h6 class="text-dark border-bottom pb-2 mb-3">
      <i class="fas fa-chart-bar me-2"></i>Statistics
    </h6>
    <div class="row text-center">
      <div class="col-md-3 col-6 mb-3">
        <div class="p-3 rounded" style="background-color: var(--pokemon-light-blue);">
          <i class="fas fa-users fa-2x text-dark mb-2"></i>
          <div class="fw-bold text-dark fs-4">{{ count }}</div>
          <small class="text-muted">{{ label }}</small>
        </div>
      </div>
    </div>
  </div>
</div>
```

### 3. **Data Tables**

```erb
<div class="card shadow-sm">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead style="background: linear-gradient(135deg, var(--pokemon-electric-blue) 0%, #0066CC 100%); color: white;">
          <tr>
            <th scope="col" class="border-0">
              <i class="fas fa-icon me-1"></i>Column Name
            </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="fw-semibold text-dark">
              <i class="fas fa-icon me-2 text-muted"></i>
              {{ content }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</div>
```

### 4. **Form Sections**

```erb
<!-- Section Header -->
<div class="row mb-4">
  <div class="col-12">
    <h5 class="text-dark border-bottom pb-2 mb-3">
      <i class="fas fa-icon me-2"></i>Section Name
    </h5>
  </div>
</div>

<!-- Form Fields -->
<div class="row">
  <div class="col-md-6 mb-3">
    <%= form.label :field, class: "form-label required" do %>
      <i class="fas fa-icon me-1"></i>Field Label
    <% end %>
    <%= form.text_field :field,
        class: "form-control #{'is-invalid' if model.errors[:field].any?}",
        placeholder: "Enter value",
        required: true %>
    <% if model.errors[:field].any? %>
      <div class="invalid-feedback">
        <%= model.errors[:field].first %>
      </div>
    <% end %>
  </div>
</div>
```

## Styling Standards

### 1. **Typography**

- **Headings**: Use `text-dark` for section headers
- **Labels**: Use `text-muted` with appropriate icons
- **Values**: Use `text-dark` with `fw-bold` for emphasis
- **Helper Text**: Use `text-muted` with `small` class

### 2. **Icons**

- **Consistent Icon Library**: Font Awesome (`fas`) throughout
- **Icon Placement**: Always include `me-1` or `me-2` spacing class
- **Semantic Icons**: Use appropriate icons for context

### 3. **Buttons**

- **Primary Actions**: `btn-primary` (for saves, submissions)
- **Secondary Actions**: `btn-outline-secondary` (for back, cancel)
- **Danger Actions**: `btn-outline-danger` (for delete)
- **Success Actions**: `btn-success` (for create, add)

#### Button Grouping Standards

- **Action buttons must be grouped together** in the action button area (before header card)
- **All buttons use standard sizing** (no `btn-sm` for action buttons)
- **Proper spacing**: Use `me-2` between buttons for consistent spacing
- **Delete buttons**: Always include in action button group, never isolate in card bodies

### 4. **Status Indicators**

#### Badge Usage Standards

- **Only show badges for exceptional states** (not normal/default states)
- **Normal states don't need badges** (e.g., "published" events, "active" students when that's the default)
- **Exception states require badges** (e.g., "cancelled", "draft", "inactive")

```erb
<!-- Event Status Badges (only show exceptions) -->
<% if @event.status == 'canceled' %>
  <span class="badge bg-danger">
    <i class="fas fa-times-circle me-1"></i>Cancelled
  </span>
<% elsif @event.status == 'draft' %>
  <span class="badge bg-secondary">
    <i class="fas fa-eye-slash me-1"></i>Draft
  </span>
<% end %>
<!-- Note: No badge for "published" status as it's the default -->

<!-- Student Status Badges -->
<% if @student.status == "active" %>
  <span class="badge bg-success">
    <i class="fas fa-check-circle me-1"></i>Active Member
  </span>
<% else %>
  <span class="badge bg-warning text-dark">
    <i class="fas fa-pause-circle me-1"></i><%= @student.status.titleize %>
  </span>
<% end %>
```

### 5. **Color-Coded Sections**

- **General Information**: Light gray backgrounds (`#f8f9fa`)
- **Pokémon Content**: Light yellow backgrounds (`var(--pokemon-light-yellow)`) with `text-dark` content
- **Notes/Special**: Light blue backgrounds (`var(--pokemon-light-blue)`)

## Modal Implementation

### Confirmation Modal Usage

**IMPORTANT**: Delete buttons must be placed in the action button area, not in card bodies.

```erb
<!-- Action Button Area (Correct Placement) -->
<div class="d-flex justify-content-between align-items-center mb-4">
  <div>
    <%= link_to back_path, class: "btn btn-outline-secondary me-2" do %>
      <i class="fas fa-arrow-left me-1"></i>Back
    <% end %>
    <%= link_to edit_path, class: "btn btn-outline-primary me-2" do %>
      <i class="fas fa-edit me-1"></i>Edit
    <% end %>
    <!-- Delete Button with Modal -->
    <% if admin? %>
      <%= form_with model: @record, method: :delete, local: true, class: "d-inline", id: "delete-record-form" do |form| %>
        <button type="button"
                class="btn btn-outline-danger"
                data-bs-toggle="modal"
                data-bs-target="#confirmationModal"
                data-confirm-title="Delete Record"
                data-confirm-message="Are you sure you want to delete this record? This action cannot be undone."
                data-confirm-action="Delete Record"
                data-form-id="delete-record-form">
          <i class="fas fa-trash me-1"></i> Delete
        </button>
      <% end %>
    <% end %>
  </div>
</div>

<!-- Include modal at bottom of page -->
<%= render "shared/generic_confirmation_modal" %>
```

## Filter and Toggle Patterns

### Toggle Switch for Filters

Use toggle switches for binary filter options like showing/hiding inactive items or cancelled events. This provides better UX than buttons by clearly showing the current state.

```erb
<div class="form-check form-switch">
  <%= form_with url: current_path, method: :get, local: true, class: "d-inline" do |form| %>
    <!-- Preserve existing filters -->
    <%= form.hidden_field :view, value: @view_mode if @view_mode %>
    <%= form.hidden_field :status, value: params[:status] if params[:status] %>
    <%= form.hidden_field :type, value: params[:type] if params[:type] %>

    <%= form.check_box :filter_param,
        {
          checked: @filter_active,
          class: "form-check-input",
          onchange: "this.form.submit();"
        },
        "true", "false" %>
    <%= form.label :filter_param, "Filter Label", class: "form-check-label" %>
  <% end %>
</div>
```

#### Examples of Toggle Implementation

**Students List - Show Inactive:**

```erb
<div class="form-check form-switch">
  <%= form_with url: students_path, method: :get, local: true, class: "d-inline" do |form| %>
    <%= form.check_box :show_inactive,
        {
          checked: @show_inactive,
          class: "form-check-input",
          onchange: "this.form.submit();"
        },
        "true", "false" %>
    <%= form.label :show_inactive, "Show inactive students", class: "form-check-label" %>
  <% end %>
</div>
```

**Events List - Show Cancelled:**

```erb
<div class="form-check form-switch">
  <%= form_with url: events_path, method: :get, local: true, class: "d-inline" do |form| %>
    <%= form.hidden_field :view, value: @view_mode %>
    <%= form.hidden_field :status, value: params[:status] %>
    <%= form.hidden_field :type, value: params[:type] %>
    <%= form.check_box :show_cancelled,
        {
          checked: params[:show_cancelled] == "true",
          class: "form-check-input",
          onchange: "this.form.submit();"
        },
        "true", "false" %>
    <%= form.label :show_cancelled, "Show cancelled events", class: "form-check-label" %>
  <% end %>
</div>
```

### Toggle Design Standards

- **Always use Bootstrap's `form-check form-switch` classes**
- **Include `onchange: "this.form.submit();"` for immediate filtering**
- **Preserve existing filters with hidden fields**
- **Use descriptive labels (e.g., "Show inactive students", "Show cancelled events")**
- **Position toggles in filter sections, typically aligned right**

## Responsive Design

### Layout Structure

- **Container**: Provided by application layout - do not add additional containers
- **Natural Width**: Let content flow naturally within the container
- **Grid Usage**: Use Bootstrap grid (`row`/`col-*`) only for multi-column content layouts, not for artificial width constraints
- **Form Fields**: Use `col-md-6` for side-by-side form inputs
- **Statistics**: Use `col-md-3`, `col-6` for dashboard stats

### Mobile Considerations

- Use `d-flex flex-column flex-md-row` for responsive layouts
- Include `mb-3` spacing for mobile stacking
- Ensure buttons have adequate touch targets

## Grade Display Pattern

```erb
<% case student.grade %>
<% when "kindergarten_grade" %>
  Kindergarten
<% when "first_grade" %>
  1st Grade
<% when "second_grade" %>
  2nd Grade
<% when "third_grade" %>
  3rd Grade
<% when "fourth_grade" %>
  4th Grade
<% when "fifth_grade" %>
  5th Grade
<% when "sixth_grade" %>
  6th Grade
<% else %>
  Grade <%= student.grade %>
<% end %>
```

## Empty States

```erb
<div class="card shadow-sm">
  <div class="card-body text-center py-5">
    <div class="mb-4">
      <i class="fas fa-icon fa-4x text-muted mb-3"></i>
      <h4 class="text-muted">No Items Found</h4>
      <p class="text-muted mb-4">
        Contextual message about why there are no items.
      </p>
      <% if can_create? %>
        <%= link_to new_item_path, class: "btn btn-primary" do %>
          <i class="fas fa-plus me-2"></i>Add First Item
        <% end %>
      <% end %>
    </div>
  </div>
</div>
```

## Admin vs User UI Patterns

### Admin-Only Sections

```erb
<% if admin? %>
  <div class="col-12 col-lg-4">
    <div class="card shadow-sm">
      <div class="card-header text-white" style="background: linear-gradient(135deg, #FFA500 0%, #FF8C00 100%);">
        <h5 class="card-title mb-0 d-flex align-items-center">
          <i class="fas fa-shield-alt me-2"></i>
          Admin Controls
        </h5>
      </div>
      <div class="card-body">
        <!-- Admin content -->
      </div>
    </div>
  </div>
<% end %>
```

## Files Updated with These Patterns

### Core Files

**Students Module:**

- `app/views/students/index.html.erb` - List view with statistics, filtering
- `app/views/students/show.html.erb` - Detail view with action button grouping
- `app/views/students/edit.html.erb` - Edit form with consistent layout
- `app/views/students/new.html.erb` - New form with header card
- `app/views/students/_form.html.erb` - Form sections with proper styling

**Events Module:**

- `app/views/events/index.html.erb` - List view with toggle filters, agenda/calendar modes
- `app/views/events/show.html.erb` - Detail view with action button grouping, status badge cleanup
- `app/views/events/edit.html.erb` - Edit form with timezone handling
- `app/views/events/new.html.erb` - New form with proper card structure
- `app/views/events/_form.html.erb` - Form with timezone conversion, clean layout

**Shared Components:**

- `app/views/shared/_generic_confirmation_modal.html.erb` - Enhanced modal with improved JavaScript

### CSS

- `app/assets/stylesheets/application.css` - Pokemon theme colors, form enhancements

## Checklist for New Pages

- [ ] Use breadcrumb navigation
- [ ] Include action buttons before header (Back, Edit, Delete grouped together)
- [ ] Header card with icon and title
- [ ] Blue text ONLY for hyperlinks
- [ ] Consistent icon usage (Font Awesome)
- [ ] Proper semantic colors
- [ ] Card-based layout structure
- [ ] Mobile-responsive design
- [ ] Include confirmation modal if needed
- [ ] Empty states for lists
- [ ] Proper admin/user permission checks
- [ ] Delete buttons in action area (never in card bodies)
- [ ] Status badges only for exceptional states (not defaults)

## Implementation Notes

1. **Always render the confirmation modal** at the bottom of pages that have delete functionality
2. **Test deletion functionality** to ensure forms submit properly
3. **Use semantic HTML** with proper ARIA labels
4. **Include loading states** for form submissions where appropriate
5. **Validate color contrast** especially for yellow text on light backgrounds

This design system ensures consistency, accessibility, and maintainability across the entire Pokémon Club website.
