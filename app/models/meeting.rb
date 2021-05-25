# == Schema Information
#
# Table name: meetings
#
#  id           :uuid             not null, primary key
#  completed_at :datetime
#  janus_secret :string
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
  include AASM
  acts_as_tenant :account
  belongs_to :host, class_name: "User"
  # TODO: this needs the actual logic to set it
  belongs_to :server, optional: true

  has_many :meeting_members
  has_many :participants, through: :meeting_members, source: :memberable, source_type: "Participant"
  has_many :documents
  has_many :signatures, through: :documents

  before_create do |meeting|
    self.janus_secret = SecureRandom.hex(16)
  end

  after_create do |meeting|
    JanusService.create_room(meeting)
  end

  aasm(column: :state, logger: Rails.logger, timestamps: true) do
    state :created, initial: true
    state :incomplete
    state :signing
    state :completed

    event :start do
      transitions from: :created, to: :incomplete
    end

    event :allow_signatures do
      transitions from: :incomplete, to: :signing, after: :freeze_meeting, guard: :all_participants_verified?
    end

    event :complete do
      transitions from: :signing, to: :completed, after: :complete_meeting
    end
  end

  def signed_room_id
    Digest::SHA1.hexdigest "#{self.id}#{ENV.fetch('SIGNATURE_SALT', 'salt is bad for you')}"
  end

  def server
    Server.first
  end

  def all_participants_verified?
    !participants.find_by(state: [:invited, :accepted]).present?
  end

  def unverified_participants
    participants.where(state: [:invited, :accepted])
  end

  private

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
end
