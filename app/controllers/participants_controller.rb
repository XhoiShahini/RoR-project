class ParticipantsController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting
  before_action :set_participant, except: [:index, :new, :create]
  before_action :require_meeting_member!, only: [:index, :show]
  before_action :require_current_account_admin, except: [:index, :show]
  before_action :cannot_modify_completed!, except: [:index, :show]

  # GET /meetings/:meeting_id/participants
  def index
    @participants = @meeting.participants
  end

  # GET /meetings/:meeting_id/participants/new
  def new
    @participant = @meeting.account.participants.new
    @participant.meeting_member = @meeting.meeting_members.new(memberable: @participant)
  end

  # POST /meetings/:meeting_id/participants
  def create
    @participant = @meeting.account.participants.new(participant_params)

    if @participant.save
      @participant.send_invite if !@meeting.is_async
      # if @meeting.is_async
      #   @participant.verify! verifier: current_user
      # end
      redirect_to new_meeting_participant_path(@meeting), notice: t("participants.notice.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /meetings/:meeting_id/participants/:id
  def show
    @host = current_account_admin?
  end

  # GET /meetings/:meeting_id/participants/:id/edit
  def edit
  end

  # PATCH/PUT /meetings/:meeting_id/participants/:id
  def update
    if @participant.update(participant_params)
      redirect_to @meeting, notice: t("participants.notice.update")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /meetings/:meeting_id/participants/:id
  def destroy
    @participant.send_removed_email
    @participant.destroy
    redirect_to @meeting, notice: t("participants.notice.destroy")
  end

  # GET /meetings/:meeting_id/participants/:id/verify
  def verify
    @participant.verify! verifier: current_user
    if @meeting.all_participants_verified?
      MeetingEventsChannel.broadcast_to @meeting, type: "participants_verified"
    end
    render plain: ""
  end

  def resend_invite
    @participant.send_invite

    redirect_to @meeting, notice: t("participants.notice.resend_invite")
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def set_participant
    @participant = Participant.find(params[:id])
  end

  def participant_params
    params[:participant][:meeting_member_attributes][:meeting_id] = @meeting.id if params[:participant].present?
    params.require(:participant).permit(
      :first_name,
      :last_name,
      :email,
      :phone_number,
      meeting_member_attributes: [
        :must_sign,
        :meeting_id
      ]
    )
  end
end