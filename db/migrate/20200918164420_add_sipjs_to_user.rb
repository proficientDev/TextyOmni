class AddSipjsToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.column :sip_target, :string, default: '', null: false
      t.column :sip_server, :string, default: '', null: false
      t.column :sip_display_name, :string, default: '', null: false
    end
  end
end
