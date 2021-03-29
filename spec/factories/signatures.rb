# == Schema Information
#
# Table name: signatures
#
#  id                :uuid             not null, primary key
#  document_read     :boolean
#  ip                :string
#  otp               :string
#  signed_at         :datetime
#  state             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  document_id       :uuid             not null
#  meeting_member_id :uuid             not null
#
# Indexes
#
#  index_signatures_on_document_id        (document_id)
#  index_signatures_on_meeting_member_id  (meeting_member_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#  fk_rails_...  (meeting_member_id => meeting_members.id)
#
FactoryBot.define do
  factory :signature do
    document { nil }
    meeting_member { nil }
    signed_at { "2021-03-26 15:34:53" }
    ip { "MyString" }
    otp { "MyString" }
    document_read { false }
  end
end
