class EventsController < ApplicationController
  allow_unauthenticated_access only: [ :index, :show ]
  before_action :set_event, only: %i[ show edit update destroy ]

  # GET /events or /events.json
  def index
    # Filter events based on user role
    base_events = current_user&.admin? ? Event.visible_to_admin : Event.visible_to_public

    # Apply filters
    @events = base_events.ordered

    # Hide cancelled events by default unless explicitly requested
    unless params[:show_cancelled] == "true"
      @events = @events.where.not(status: "canceled")
    end

    # Filter by status if specified (but not cancelled, handled above)
    if params[:status].present? && params[:status] != "canceled"
      @events = @events.where(status: params[:status])
    end

    # Filter by type (special/regular) if specified
    if params[:type] == "special"
      @events = @events.special
    elsif params[:type] == "regular"
      @events = @events.regular
    end

    # Default view mode (calendar or list)
    @view_mode = params[:view] || "calendar"

    # For agenda view, only show current and upcoming events
    if @view_mode == "list"
      @events = @events.upcoming
    end

    # For calendar view, prepare data for FullCalendar
    if @view_mode == "calendar"
      @calendar_events = @events.map do |event|
        {
          id: event.id,
          title: event.title,
          starts_at: event.starts_at.iso8601,
          ends_at: event.ends_at.iso8601,
          status: event.status,
          special: event.special?,
          description: event.description,
          venue: event.venue
        }
      end
    end
  end

  # GET /events/1 or /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
    # Pre-populate with default school address
    @event.venue = "Lake Elementary School"
    @event.address1 = "4950 Lake Blvd"
    @event.city = "Oceanside"
    @event.state = "CA"
    @event.zipcode = "92056"
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = Event.new(event_params_with_timezone_conversion)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params_with_timezone_conversion)
        format.html { redirect_to @event, notice: "Event was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy!

    respond_to do |format|
      format.html { redirect_to events_path, notice: "Event was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.expect(event: [ :title, :description, :starts_at, :ends_at, :time_zone, :venue, :address1, :address2, :city, :state, :zipcode, :status, :special ])
    end

    # Convert datetime parameters from form timezone to UTC
    def event_params_with_timezone_conversion
      permitted_params = event_params

      # Get timezone from params
      timezone_name = permitted_params[:time_zone]
      return permitted_params unless timezone_name.present?

      timezone = ActiveSupport::TimeZone[timezone_name]
      return permitted_params unless timezone

      # Convert starts_at if present
      if permitted_params[:starts_at].present?
        # Convert datetime-local format (2025-09-13T20:30) to timezone-aware UTC
        local_time_str = permitted_params[:starts_at].to_s.gsub("T", " ")
        permitted_params[:starts_at] = timezone.parse(local_time_str).utc
      end

      # Convert ends_at if present
      if permitted_params[:ends_at].present?
        # Convert datetime-local format (2025-09-13T20:30) to timezone-aware UTC
        local_time_str = permitted_params[:ends_at].to_s.gsub("T", " ")
        permitted_params[:ends_at] = timezone.parse(local_time_str).utc
      end

      permitted_params
    end
end
