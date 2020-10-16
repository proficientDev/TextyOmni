class CreateAvailabilityStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :availability_statuses do |t|
      t.integer :user_id
      t.string :availability

      t.timestamps
    end
  end
end
