class CreateEmailSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :email_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :subscription_type
      t.boolean :enabled

      t.timestamps
    end
  end
end
