class CreateDonations < ActiveRecord::Migration[8.0]
  def change
    create_table :donations do |t|
      t.references :donor, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :donation_type, null: false
      t.date :donation_date, null: false
      t.text :notes

      t.timestamps
    end

    add_index :donations, [ :donor_id, :donation_date ]
    add_index :donations, :donation_date
  end
end
