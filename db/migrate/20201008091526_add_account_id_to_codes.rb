class AddAccountIdToCodes < ActiveRecord::Migration[6.0]
  def change
    add_column :codes, :account_id, :integer
  end
end
