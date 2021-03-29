# == Schema Information
#
# Table name: sms_verifications
#
#  id                  :uuid             not null, primary key
#  code                :string
#  error               :string
#  phone_number        :string
#  sent_at             :datetime
#  sms_verifiable_type :string           not null
#  state               :string
#  verified_at         :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  messagebird_id      :string
#  sms_verifiable_id   :uuid             not null
#
# Indexes
#
#  index_sms_verifications_on_sms_verifiable  (sms_verifiable_type,sms_verifiable_id)
#
FactoryBot.define do
  factory :sms_verification do
    sms_verifiable { nil }
    code { "MyString" }
    error { "MyString" }
    phone_number { "MyString" }
    sent_at { "2021-03-28 12:04:31" }
    verified_at { "2021-03-28 12:04:31" }
    messagebird_id { "MyString" }
  end
end
