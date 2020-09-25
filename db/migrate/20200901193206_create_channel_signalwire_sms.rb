class CreateChannelSignalwireSms < ActiveRecord::Migration[6.0]
  def change
    create_table :channel_signalwire_sms do |t|
      t.string :phone_number, null: false
      t.string :auth_token, null: false
      t.string :account_sid, null: false
      t.string :space_url, null: false
      t.integer :account_id, null: false
      t.integer :medium, null: false, index: true, default: 0
      t.timestamps
    end
    add_index :channel_signalwire_sms, [:account_id, :phone_number], unique: true
  end
end
