# == Schema Information
#
# Table name: channel_signalwire_sms
#
#  id           :bigint           not null, primary key
#  account_sid  :string           not null
#  auth_token   :string           not null
#  medium       :integer          default("sms"), not null
#  phone_number :string           not null
#  space_url    :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :integer          not null
#
# Indexes
#
#  index_channel_signalwire_sms_on_account_id_and_phone_number  (account_id,phone_number) UNIQUE
#  index_channel_signalwire_sms_on_medium                       (medium)
#
class Channel::SignalwireSms < ApplicationRecord
  self.table_name = 'channel_signalwire_sms'

  validates :account_id, presence: true
  validates :account_sid, presence: true
  validates :space_url, presence: true
  validates :auth_token, presence: true
  validates :phone_number, uniqueness: { scope: :account_id }, presence: true

  enum medium: { sms: 0 }

  belongs_to :account

  has_one :inbox, as: :channel, dependent: :destroy

  def has_24_hour_messaging_window?
    true
  end

  def name
    'SignalWire SMS'
  end
end
