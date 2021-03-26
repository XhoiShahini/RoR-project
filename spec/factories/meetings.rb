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
#
# Indexes
#
#  index_meetings_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
FactoryBot.define do
  factory :meeting do
    creator { nil }
    title { "MyString" }
    starts_at { "2021-03-26 14:35:29" }
  end
end
