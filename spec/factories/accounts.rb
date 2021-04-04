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
FactoryBot.define do
  factory :account do
    name { Faker::Company.name }
    association :owner, factory: :user
  end
end
