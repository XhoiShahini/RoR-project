# Preview all emails at http://localhost:3000/rails/mailers/post_meeting
class PostMeetingPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/post_meeting/post_meeting
  def post_meeting
    PostMeetingMailer.post_meeting
  end

end
