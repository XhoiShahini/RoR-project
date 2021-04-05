class ParticipantsMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.participants_mailer.invite.subject
  #
  def invite
    @participant = params[:participant]
    name = @participant.name
    email = @participant.email
    @meeting = @participant.meeting

    mail(
      to: "#{name} <#{email}>",
      from: "#{@meeting.account.name} <#{Jumpstart.config.support_email}>",
      subject: t(".subject", meeting: @meeting.title)
    )
  end
end
