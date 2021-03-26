# == Schema Information
#
# Table name: participants
#
#  id                  :uuid             not null, primary key
#  accepted_privacy_at :datetime
#  accepted_terms_at   :datetime
#  email               :string
#  first_name          :string
#  last_name           :string
#  phone_number        :string
#  state               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :uuid             not null
#
# Indexes
#
#  index_participants_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
FactoryBot.define do
  factory :participant do
    meeting { nil }
    first_name { "MyString" }
    last_name { "MyString" }
    email { "MyString" }
    phone_number { "MyString" }
    accepted_terms_at { "2021-03-26 14:53:10" }
    accepted_privacy_at { "2021-03-26 14:53:10" }
  end
end
