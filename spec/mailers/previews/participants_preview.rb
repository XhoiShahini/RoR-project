# Preview all emails at http://localhost:3000/rails/mailers/participants
class ParticipantsPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/participants/invite
  def invite
    ParticipantsMailer.invite
  end

end
