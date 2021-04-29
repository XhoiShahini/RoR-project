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
      @participant.accept! if @participant.invited?
      redirect_to meeting_path(@meeting), notice: I18n.t("participants.sign_in.success")
    else
      redirect_to meeting_participant_sign_in_path(@meeting, @participant), notice: @sms_verification.error
    end
  end

  # GET /meetings/:meeting_id/participants/:id/sign_in/otp
  def otp
    @sms_verification = @participant.sms_verifications.create(phone_number: @participant.phone_number)
  end

  def send_otp
    if params[:data_processing] == "1" && params[:media_processing] == "1" && params[:signature_processing] == "1"
      redirect_to otp_meeting_participant_sign_in_path(@meeting, @participant)
    else
      redirect_to meeting_participant_sign_in_path(@meeting, @participant), alert: t("participants.sign_in.must_accept_terms")
    end
  end

  # DELETE /meetings/:meeting_id/participants/:id/sign_in
  def destroy
    session.delete(:participant_id)
    redirect_to root_path, notice: t("participants.sign_in.signed_out")
  end
  
  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def set_participant
    @participant = Participant.find(params[:participant_id])
  end
end