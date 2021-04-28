# == Schema Information
#
# Table name: participants
#
#  id                    :uuid             not null, primary key
#  accepted_data_at      :datetime
#  accepted_media_at     :datetime
#  accepted_privacy_at   :datetime
#  accepted_signature_at :datetime
#  accepted_terms_at     :datetime
#  email                 :string
#  first_name            :string
#  last_name             :string
#  phone_number          :string
#  state                 :string
#  verified_at           :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_id            :uuid             not null
#  verifier_id           :uuid
#
# Indexes
#
#  index_participants_on_account_id   (account_id)
#  index_participants_on_verifier_id  (verifier_id)
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
