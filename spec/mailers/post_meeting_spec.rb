require "rails_helper"

RSpec.describe PostMeetingMailer, type: :mailer do
  describe "post_meeting" do
    let(:mail) { PostMeetingMailer.post_meeting }

    it "renders the headers" do
      expect(mail.subject).to eq("Post meeting")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
