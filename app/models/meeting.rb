# == Schema Information
#
# Table name: meetings
#
#  id           :uuid             not null, primary key
#  completed_at :datetime
#  starts_at    :datetime
#  state        :string
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :uuid             not null
#  host_id      :uuid             not null
#
# Indexes
#
#  index_meetings_on_account_id  (account_id)
#  index_meetings_on_host_id     (host_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Meeting < ApplicationRecord
  acts_as_tenant :account
  belongs_to :host, class: "User"

  has_many :meeting_members
  has_many :documents
  has_many :signatures, through: :documents
end
