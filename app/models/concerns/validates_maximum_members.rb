module ValidatesMaximumMembers
  extend ActiveSupport::Concern

  included do
    validate :enforce_maximum_members, on: :create
  end

  def enforce_maximum_members
    # STRIPE FOR LUCA
    max_members = case meeting.account.subscription&.plan&.name
    when /entry/i
      5
    when /evo/i
      5
    when /pro/i
      5
    else
      2
    end
    if meeting&.meeting_members.count >= max_members
      errors.add(:meeting, I18n.t("meetings.maximum_members", maximum: max_members))
    end
  end
end