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
require 'aasm'
class Participant < ApplicationRecord
  class Verification
    def initialize(participant, args = {})
      @participant = participant
      @verifier = args[:verifier]
      @verified_at = Time.now
    end
  
    def call
      @participant.update(verified_at: @verified_at, verifier: @verifier)
    end
  end
  include AASM
  include IdentificationAttached
  has_person_name

  acts_as_tenant :account
  belongs_to :verifier, class_name: "User", optional: true

  has_one :meeting_member, as: :memberable, dependent: :destroy
  has_one :meeting, through: :meeting_member
  has_many :signatures, through: :meeting_member
  has_many :sms_verifications, as: :sms_verifiable

  after_create { send_invite }
  before_destroy { send_removed_email }
  after_update_commit { MeetingMembersChannel.broadcast_to meeting, type: "update" }
  validate :send_invite, on: :update, if: -> { email_changed? }

  accepts_nested_attributes_for :meeting_member

  aasm(column: :state, logger: Rails.logger) do
    state :invited, initial: true
    state :accepted
    state :verified
    state :finalized

    event :accept do
      transitions from: :invited, to: :accepted
    end

    # Takes a verifier argument
    event :verify do
      transitions from: :accepted, to: :verified, after: Verification
    end

    event :finalize do
      transitions from: :verified, to: :finalized
    end
  end

  def send_invite
    ParticipantsMailer.with(participant: self).invite.deliver_later
  end

  def send_removed_email
    ParticipantsMailer.with(participant: self).removed.deliver_later
  end
end
