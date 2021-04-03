module ValidatesMaximumMembers
  extend ActiveSupport::Concern

  included do
    validate :enforce_maximum_members, on: :create
  end

  def enforce_maximum_members
    # STRIPE FOR LUCA
    max_members = 4
    if meeting&.meeting_members.count >= max_members
      errors.add(:meeting, I18n.t("meetings.maximum_members", maximum: max_members))
    end
  end
end