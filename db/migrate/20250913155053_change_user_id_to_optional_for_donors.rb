class ChangeUserIdToOptionalForDonors < ActiveRecord::Migration[8.0]
  def change
    change_column_null :donors, :user_id, true
  end
end
