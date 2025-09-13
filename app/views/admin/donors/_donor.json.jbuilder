json.extract! donor, :id, :name, :donor_type, :donation_amount, :donation_type, :privacy_setting, :website_link, :created_at, :updated_at
json.url donor_url(donor, format: :json)
