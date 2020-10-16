# == Schema Information
#
# Table name: availability_statuses
#
#  id           :bigint           not null, primary key
#  availability :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer
#
class AvailabilityStatus < ApplicationRecord
  include RegexHelper
  belongs_to :user
end
