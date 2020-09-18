class AddSipFieldsToUser < ActiveRecord::Migration[6.0]
  change_table :users, bulk: true do |t|
    t.string :sip_target, default: ''
    t.string :sip_target, default: ''
    t.string :sip_target, default: ''
  end
end
