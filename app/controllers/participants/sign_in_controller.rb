class Participants::SignInController < ApplicationController
  before_action :set_meeting
  before_action :set_participant
  # GET /meetings/:meeting_id/participants/:id/sign_in
  def show
  end

  # POST /meetings/:meeting_id/participants/:id/sign_in
  def create
    @sms_verification = SmsVerification.find(params[:sms_verification_id])
    @sms_verification.verify_code! params[:code]

    if @sms_verification.verified?
      session[:participant_id] = @participant.id
      redirect_to pre_meeting_meeting_room_path(@meeting)
    else
      redirect_to :show, notice: @sms_verification.error
    end
  end

  # GET /meetings/:meeting_id/participants/:id/sign_in/otp
  def otp
    @sms_verification = @participant.sms_verifications.create(phone_number: @participant.phone_number)
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def set_participant
    @participant = Participant.find(params[:participant_id])
  end
end