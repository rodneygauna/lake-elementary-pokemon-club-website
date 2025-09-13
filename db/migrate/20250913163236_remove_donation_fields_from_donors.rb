class RemoveDonationFieldsFromDonors < ActiveRecord::Migration[8.0]
  def change
    remove_column :donors, :donation_amount, :decimal
    remove_column :donors, :donation_type, :string
  end
end
