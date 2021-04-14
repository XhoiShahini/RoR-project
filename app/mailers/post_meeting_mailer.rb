class PostMeetingMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.post_meeting_mailer.post_meeting.subject
  #
  def post_meeting
    @meeting_member = params[:meeting_member]
    @memberable = @meeting_member.memberable
    name = @memberable.name
    email = @memberable.email
    @meeting = @meeting_member.meeting

    @meeting_url = if @meeting_member.memberable_type == "Participant"
      meeting_participant_sign_in_url(@meeting, @memberable)
    else
      meeting_url(@meeting)
    end

    mail(
      to: "#{name} <#{email}>",
      from: "#{@meeting.account.name} <#{Jumpstart.config.support_email}>",
      subject: t(".subject", meeting: @meeting.title)
    )
  end
end
