class CreateDonors < ActiveRecord::Migration[8.0]
  def change
    create_table :donors do |t|
      t.string :name
      t.string :donor_type
      t.decimal :donation_amount
      t.string :donation_type
      t.string :privacy_setting
      t.string :website_link

      t.timestamps
    end
  end
end
