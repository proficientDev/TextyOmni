class ChangeUserToBeString < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :availability, :string
  end
  
  def down
    change_column :users, :availability, :integer
  end
end
