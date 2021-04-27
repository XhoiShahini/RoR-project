# == Schema Information
#
# Table name: meeting_members
#
#  id              :uuid             not null, primary key
#  audio           :boolean          default(TRUE)
#  janus_token     :string
#  memberable_type :string           not null
#  must_sign       :boolean
#  video           :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  company_id      :uuid
#  meeting_id      :uuid             not null
#  memberable_id   :uuid             not null
#
# Indexes
#
#  index_meeting_members_on_company_id  (company_id)
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
  belongs_to :company, optional: true

  has_many :signatures, dependent: :destroy
  has_many :document_accesses
  has_many :meeting_accesses

  before_create do |meeting|
    self.janus_token = SecureRandom.hex(16)
  end

  after_create do |meeting_member|
    JanusService.create_and_add_token(meeting_member)
  end

  include ValidatesMaximumMembers
  after_create :initialize_signatures
  after_create_commit { broadcast_to_meeting("create") }
  after_update_commit { broadcast_to_meeting("update") }
  after_destroy_commit { broadcast_to_meeting("destroy") }

  delegate :server, to: :meeting

  def signed_member_id
    Digest::SHA1.hexdigest "#{self.id}#{ENV.fetch('SIGNATURE_SALT', 'salt is bad for you')}"
  end

  def full_name
    "#{self.memberable.first_name} #{self.memberable.last_name}"
  end

  def is_moderator?
    # TODO: currently any User is a moderator
    self.memberable.is_a? User
  end

  private

  def broadcast_to_meeting(type)
    MeetingMembersChannel.broadcast_to meeting, type: type, document_id: id
  end

  def initialize_signatures
    meeting.documents.each do |document|
      document.signatures.create(meeting_member: self)
    end
  end
end
