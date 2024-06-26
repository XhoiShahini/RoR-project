# == Schema Information
#
# Table name: users
#
#  id                              :uuid             not null, primary key
#  accepted_marketing_at           :datetime
#  accepted_privacy_at             :datetime
#  accepted_signature_agreement_at :datetime
#  accepted_terms_at               :datetime
#  admin                           :boolean
#  announcements_read_at           :datetime
#  confirmation_sent_at            :datetime
#  confirmation_token              :string
#  confirmed_at                    :datetime
#  email                           :string           default(""), not null
#  encrypted_password              :string           default(""), not null
#  first_name                      :string
#  invitation_accepted_at          :datetime
#  invitation_created_at           :datetime
#  invitation_limit                :integer
#  invitation_sent_at              :datetime
#  invitation_token                :string
#  invitations_count               :integer          default(0)
#  invited_by_type                 :string
#  last_name                       :string
#  phone_number                    :string
#  preferred_language              :string
#  remember_created_at             :datetime
#  reset_password_sent_at          :datetime
#  reset_password_token            :string
#  time_zone                       :string
#  unconfirmed_email               :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  invited_by_id                   :uuid
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by            (invited_by_type,invited_by_id)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user has many accounts" do
    user = users(:one)
    assert_includes user.accounts, accounts(:one)
    assert_includes user.accounts, accounts(:company)
  end

  test "user has a personal account" do
    user = users(:one)
    assert_equal accounts(:one), user.personal_account
  end

  test "can delete user with accounts" do
    assert_difference "User.count", -1 do
      users(:one).destroy
    end
  end
end
