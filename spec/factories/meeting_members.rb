# == Schema Information
#
# Table name: meeting_members
#
#  id              :uuid             not null, primary key
#  company         :string
#  memberable_type :string           not null
#  must_sign       :boolean
#  verified_at     :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  meeting_id      :uuid             not null
#  memberable_id   :uuid             not null
#  verifier_id     :uuid
#
# Indexes
#
#  index_meeting_members_on_meeting_id  (meeting_id)
#  index_meeting_members_on_memberable  (memberable_type,memberable_id)
#
# Foreign Keys
#
#  fk_rails_...  (meeting_id => meetings.id)
#
FactoryBot.define do
  factory :meeting_member do
    meeting { nil }
    memberable { nil }
    company { "MyString" }
    must_sign { false }
    verified_at { "2021-03-26 15:08:15" }
    verifier_id { "" }
  end
end
