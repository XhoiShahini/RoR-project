# == Schema Information
#
# Table name: meeting_members
#
#  id               :uuid             not null, primary key
#  audio            :boolean          default(TRUE)
#  memberable_type  :string           not null
#  must_sign        :boolean
#  video            :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company_id       :uuid
#  meeting_id       :uuid             not null
#  memberable_id    :uuid             not null
#  signed_member_id :string
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
  has_paper_trail
  belongs_to :meeting
  belongs_to :memberable, polymorphic: true
  belongs_to :company, optional: true

  has_many :signatures, dependent: :destroy
  has_many :document_accesses
  has_many :meeting_accesses

  before_create do |meeting|
    self.set_signed_member_id
  end

  include ValidatesMaximumMembers
  after_create :initialize_signatures
  after_create_commit { broadcast_to_meeting("create") }
  after_update_commit { broadcast_to_meeting("update") }
  after_destroy_commit { broadcast_to_meeting("destroy") }

  delegate :server, to: :meeting

  def set_signed_member_id
    self.signed_member_id = Digest::SHA1.hexdigest "#{self.id}#{rand()}#{ENV.fetch('SIGNATURE_SALT', 'salt is bad for you')}"
  end

  def full_name
    "#{self.memberable.first_name} #{self.memberable.last_name}"
  end

  def is_moderator?
    # TODO: currently any User is a moderator
    self.memberable.is_a? User
  end

  def finalized?
    memberable_type == "Participant" && memberable.finalized?
  end

  def verifiable?
    memberable_type == "Participant" && !memberable.invited?
  end

  def toggle_audio(value)
    setting = value == 'true'
    Rails.logger.debug value
    Rails.logger.debug setting
    MeetingMembersChannel.broadcast_to self.meeting, type: "presence", id: self.signed_member_id, audio: setting
  end

  def toggle_video(value)
    setting = value == 'true'
    Rails.logger.debug value
    Rails.logger.debug setting
    MeetingMembersChannel.broadcast_to self.meeting, type: "presence", id: self.signed_member_id, video: setting
  end

  def reset_media!
    self.video = true
    self.audio = true
    self.save
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
