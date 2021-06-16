module UserAgreements
  extend ActiveSupport::Concern

  included do
    # Accept the terms of service on registration
    attribute :terms_of_service
    validates :terms_of_service, presence: true, acceptance: true, on: [:create, :invitation_accepted]

    attribute :privacy_policy
    validates :privacy_policy, presence: true, acceptance: true, on: [:create, :invitation_accepted]

    attribute :signature_agreement
    validates :signature_agreement, presence: true, acceptance: true, on: [:create, :invitation_accepted]

    attribute :marketing_agreement
    validates :marketing_agreement, presence: true, acceptance: false, on: [:create, :invitation_accepted]

    after_validation :accept_terms, on: [:create, :invitation_accepted]
    after_validation :accept_privacy, on: [:create, :invitation_accepted]
    after_validation :accept_signature_agreement, on: [:create, :invitation_accepted]
    after_validation :accept_marketing, on: [:create, :invitation_accepted], if: -> { marketing_agreement == "1" }
  end

  def accept_terms
    self.accepted_terms_at = Time.zone.now
  end

  def accept_privacy
    self.accepted_privacy_at = Time.zone.now
  end

  def accept_signature_agreement
    self.accepted_signature_agreement_at = Time.zone.now
  end

  def accept_marketing
    self.accepted_marketing_at = Time.zone.now
  end
end
