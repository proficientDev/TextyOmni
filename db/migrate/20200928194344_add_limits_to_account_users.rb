class AddLimitsToAccountUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :account_users, :limits, :integer
  end
end
