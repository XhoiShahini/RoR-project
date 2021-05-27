module MeetingsHelper
  def require_meeting_member!
    if memberable = current_user || current_participant
      @meeting_member = @meeting.meeting_members.find_by(memberable: memberable)
      unless @meeting_member.present? || (current_account.present? && current_account_admin?)
        redirect_to meetings_path, alert: I18n.t("meetings.notice.not_authorized")
      end
    else
      authenticate_user!
    end
  end

  def cannot_modify_completed!
    unless @meeting.created? || @meeting.incomplete?
      redirect_to @meeting, alert: t("meetings.notice.cannot_be_modified")
    end
  end
end
