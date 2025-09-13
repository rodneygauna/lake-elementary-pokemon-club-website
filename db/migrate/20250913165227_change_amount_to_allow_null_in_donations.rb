class ChangeAmountToAllowNullInDonations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :donations, :amount, true
  end
end
