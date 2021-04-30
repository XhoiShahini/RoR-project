class Participants::IdUploadsController < ApplicationController
  before_action :set_meeting
  before_action :require_same_participant!

  # GET /users/id_upload/new
  def new
  end

  # POST /users/id_upload
  def create
    if @participant.update(id_upload_params)
      MeetingMembersChannel.broadcast_to @meeting, type: "update"
      redirect_to new_meeting_participant_id_upload_path(@meeting, @participant)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/id_upload
  def show
  end

  private

  def id_upload_params
    params.require(:participant).permit(:identification)
  end

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def require_same_participant!
    @participant = @meeting.participants.find(params[:participant_id])
    unless current_participant && current_participant == @participant
      redirect_to @meeting, notice: t('meetings.room.pre_meeting.upload_id.require_same_participant')
    end
  end
end