# == Schema Information
#
# Table name: meeting_accesses
#
#  id                :uuid             not null, primary key
#  ip                :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  meeting_member_id :uuid             not null
#
# Indexes
#
#  index_meeting_accesses_on_meeting_member_id  (meeting_member_id)
#
# Foreign Keys
#
#  fk_rails_...  (meeting_member_id => meeting_members.id)
#
FactoryBot.define do
  factory :meeting_access do
    meeting_member { nil }
    ip { "MyString" }
  end
end
