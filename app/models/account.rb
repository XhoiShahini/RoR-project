# == Schema Information
#
# Table name: accounts
#
#  id                 :uuid             not null, primary key
#  card_exp_month     :string
#  card_exp_year      :string
#  card_last4         :string
#  card_type          :string
#  domain             :string
#  extra_billing_info :text
#  name               :string           not null
#  personal           :boolean          default(FALSE)
#  processor          :string
#  subdomain          :string
#  trial_ends_at      :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  owner_id           :uuid
#  processor_id       :string
#
# Indexes
#
#  index_accounts_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#

class Account < ApplicationRecord
  has_paper_trail
  include Pay::Billable

  RESERVED_DOMAINS = [Jumpstart.config.domain]
  RESERVED_SUBDOMAINS = %w[app help support]

  belongs_to :owner, class_name: "User"
  has_many :account_invitations, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :users, through: :account_users
  has_many :participants
  has_many :meetings
  has_many :companies

  scope :personal, -> { where(personal: true) }
  scope :impersonal, -> { where(personal: false) }

  has_noticed_notifications
  has_one_attached :avatar

  validates :name, presence: true
  validates :domain, exclusion: {in: RESERVED_DOMAINS, message: :reserved}
  validates :subdomain, exclusion: {in: RESERVED_SUBDOMAINS, message: :reserved}, format: {with: /\A[a-zA-Z0-9]+[a-zA-Z0-9\-_]*[a-zA-Z0-9]+\Z/, message: :format, allow_blank: true}

  def email
    account_users.includes(:user).order(created_at: :asc).first.user.email
  end

  def personal_account_for?(user)
    personal? && owner_id == user.id
  end

  def used_meetings_count
    meetings.where(state: [:signing, :completed]).where("starts_at >= ?", DateTime.current.beginning_of_month).count
  end

  def maximum_meetings
    case subscription&.plan&.name
    when /entry/i
      30
    when /evo/i
      70
    when /pro/i
      160
    else
      freemium_meetings
    end
  end

  def freemium_meetings
    Rails.env.development? ? 100 : ENV.fetch('FREEMIUM_MEETINGS', 3).to_i
  end

  def meeting_usable?
    used_meetings_count < maximum_meetings
  end

  # Uncomment this to add generic trials (without a card or plan)
  #
  # before_create do
  #   self.trial_ends_at = 14.days.from_now
  # end

  # If you need to create some associated records when an Account is created,
  # use a `with_tenant` block to change the current tenant temporarily
  #
  # after_create do
  #   ActsAsTenant.with_tenant(self) do
  #     association.create(name: "example")
  #   end
  # end
end
