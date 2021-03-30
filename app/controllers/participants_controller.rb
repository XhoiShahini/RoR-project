class ParticipantsController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting
  before_action :set_participant, except: [:index, :new, :create]
  before_action :require_meeting_member!, only: [:index, :show]
  before_action :require_current_account_admin, except: [:index, :show]
  before_action :cannot_modify_completed!, except: [:index, :show]

  # GET /meetings/:meeting_id/participants
  def index
    # TODO Ransack
    @pagy, @meetings = pagy(Meeting.sort_by_params(params[:sort], sort_direction))

    # We explicitly load the records to avoid triggering multiple DB calls in the views when checking if records exist and iterating over them.
    # Calling @sms_verifications.any? in the view will use the loaded records to check existence instead of making an extra DB call.
    @meetings.load
  end

  # GET /meetings/:meeting_id/participants/new
  def new
    @participant = @meeting.participants.new
  end

  # POST /meetings/:meeting_id/participants
  def create
    @participant = @meeting.participants.new(participant_params)

    if @participant.save
      redirect_to @meeting, notice: t("participants.notice.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /meetings/:meeting_id/participants/:id
  def show
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
    @participant.destroy
    redirect_to @meeting, notice: t("participants.notice.destroy")
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