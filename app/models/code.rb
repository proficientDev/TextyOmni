# == Schema Information
#
# Table name: codes
#
#  id          :bigint           not null, primary key
#  description :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :integer
#
class Code < ApplicationRecord
end
