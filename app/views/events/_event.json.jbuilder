json.extract! event, :id, :title, :description, :starts_at, :ends_at, :time_zone, :venue, :address1, :address2, :city, :state, :zipcode, :status, :created_at, :updated_at
json.url event_url(event, format: :json)
