# == Schema Information
#
# Table name: companies
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :uuid             not null
#
# Indexes
#
#  index_companies_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Company < ApplicationRecord
  acts_as_tenant :account
  has_many :meeting_members

  def members
    meeting_members.map { |mm| mm.memberable }.uniq
  end

  def meetings
    meeting_members.map { |mm| mm.meeting }.uniq
  end
end
