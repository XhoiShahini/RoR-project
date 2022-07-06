# == Schema Information
#
# Table name: meetings
#
#  id           :uuid             not null, primary key
#  completed_at :datetime
#  is_async     :boolean          default(FALSE)
#  starts_at    :datetime
#  state        :string
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :uuid             not null
#  host_id      :uuid             not null
#  server_id    :uuid
#
# Indexes
#
#  index_meetings_on_account_id  (account_id)
#  index_meetings_on_host_id     (host_id)
#  index_meetings_on_server_id   (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (server_id => servers.id)
#
require 'aasm'
require 'securerandom'

class Meeting < ApplicationRecord
  has_paper_trail
  include AASM
  acts_as_tenant :account
  belongs_to :host, class_name: "User"
  # TODO: this needs the actual logic to set it
  belongs_to :server, optional: true

  has_many :meeting_members
  has_many :participants, through: :meeting_members, source: :memberable, source_type: "Participant"
  has_many :documents
  has_many :signatures, through: :documents
  validate :meeting_modifiable, on: [:update]

  aasm(column: :state, logger: Rails.logger, timestamps: true) do
    state :created, initial: true
    state :incomplete
    state :signing
    state :completed

    event :start do
      transitions from: :created, to: :incomplete
    end

    event :allow_signatures do
      transitions from: :incomplete, to: :signing, after: :freeze_meeting, guards: [:all_participants_verified?, :meeting_credits_available?]
    end

    event :complete do
      transitions from: [:incomplete, :signing], to: :completed, after: :complete_meeting
    end
  end

  before_create do
    if self.is_async
      self.starts_at = Time.now
    end
  end

  def signed_room_id
    Digest::SHA1.hexdigest "#{self.id}#{ENV.fetch('SIGNATURE_SALT', 'salt is bad for you')}"
  end

  def server
    Server.first
  end

  def all_participants_verified?
    !participants.includes(:meeting_member).where(meeting_member: { must_sign: true }).find_by(state: [:invited, :accepted]).present?
  end

  def unverified_participants
    participants.where(state: [:invited, :accepted])
  end

  def meeting_credits_available?
    account.meeting_usable?
  end

  def complete_if_all_signed
    puts "CHECKING IF ALL SIGNED FROM MODEL"
    complete! if all_signed?
  end

  private

  def meeting_modifiable
    errors.add(:meeting, I18n.t("meetings.notice.cannot_be_modified")) unless created? || incomplete? || state_changed? || is_async
  end

  def broadcast_start
    MeetingEventsChannel.broadcast_to self, type: "start"
  end

  def freeze_meeting
    participants.each do |participant|
      participant.finalize!
    end
    documents.each do |document|
      # Finalizes the document
      document.sign!
    end
    MeetingEventsChannel.broadcast_to self, type: "start_signing"
  end

  def complete_meeting
    MeetingEventsChannel.broadcast_to self, type: "end"
    meeting_members.each do |member|
      PostMeetingMailer.with(meeting_member: member).post_meeting.deliver_later
    end
  end

  def all_signed?
    documents.where(read_only: false).each do |doc|
      puts "Document FINALIZED is #{doc.finalized?}"
      return false if !doc.finalized?
    end
    return true
  end
end
