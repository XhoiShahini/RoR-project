# == Schema Information
#
# Table name: meeting_members
#
#  id              :uuid             not null, primary key
#  company         :string
#  memberable_type :string           not null
#  must_sign       :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  meeting_id      :uuid             not null
#  memberable_id   :uuid             not null
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
class MeetingMember < ApplicationRecord
  belongs_to :meeting
  belongs_to :memberable, polymorphic: true

  has_many :signatures
  has_many :document_accesses
  has_many :meeting_accesses

  after_create :initialize_signatures

  private

  def initialize_signatures
    meeting.documents.each do |document|
      document.signatures.create(meeting_member: self)
    end
  end
end
