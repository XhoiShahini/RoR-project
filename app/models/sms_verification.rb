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
require 'aasm'
require 'messagebird'
class SmsVerification < ApplicationRecord
  has_paper_trail
  include AASM
  belongs_to :sms_verifiable, polymorphic: true

  after_create_commit { send_code! }

  aasm(column: :state, logger: Rails.logger) do
    state :created, initial: true
    state :sent
    state :failed
    state :verified

    event :send_code do
      transitions from: :created, to: :sent do
        guard do
          send_sms
          sms_sent?
        end
      end
    end

    event :verify do
      transitions from: :sent, to: :verified do
        guard do
          verified_at.present?
        end
      end
    end

    event :reject_code do
      transitions from: :sent, to: :failed
    end
  end

  def send_sms
    client = MessageBird::Client.new(ENV.fetch("MESSAGEBIRD_KEY", ""))
    messagebird = client.verify_create(
      phone_number.to_i,
      template: I18n.t("sms_verifications.template"), 
      timeout: ENV.fetch("MESSAGEBIRD_TIMEOUT", "300").to_i
    )
    update(sent_at: Time.now, messagebird_id: messagebird.id)
  end

  def verify_code!(attempt = "")
    self.code = attempt
    client = MessageBird::Client.new(ENV.fetch("MESSAGEBIRD_KEY", ""))
    
    begin
      messagebird = client.verify_token(messagebird_id, code)
    rescue => e
      self.error = e.errors.map { |err| err.description }.join(". ")
    end

    if messagebird&.status == "verified"
      self.verified_at = Time.now
      verify!
    else
      self.error ||= I18n.t("sms_verifications.invalid_code")
      reject_code!
    end
  end

  def sms_sent?
    sent_at.present?
  end
end
