module MeetingsHelper
  def require_meeting_member!
    @meeting_member = @meeting.meeting_members.find_by(memberable: current_user || current_participant)
    unless @meeting_member.present? || current_account_admin?
      redirect_to meetings_path, alert: I18n.t("meetings.notice.not_authorized")
    end
  end

  def cannot_modify_completed!
    if @meeting.completed?
      redirect_to @meeting, alert: t("meetings.notice.cannot_be_modified")
    end
  end
end
