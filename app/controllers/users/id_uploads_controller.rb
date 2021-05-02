class Users::IdUploadsController < ApplicationController
  before_action :authenticate_user!

  # GET /users/id_upload/new
  def new
    @meeting_id = params[:meeting_id]
  end

  # POST /users/id_upload
  def create
    @meeting = Meeting.find(params[:meeting_id])
    if current_user.update(id_upload_params)
      MeetingMembersChannel.broadcast_to @meeting, type: "update"
    end
    redirect_to pre_meeting_meeting_room_path(@meeting)
  end

  # GET /users/id_upload
  def show
  end

  def destroy
    @meeting = Meeting.find(params[:meeting_id])
    current_user.identification.destroy
    MeetingMembersChannel.broadcast_to @meeting, type: "update"
    redirect_to pre_meeting_meeting_room_path(@meeting)
  end

  private

  def id_upload_params
    params.require(:user).permit(:identification)
  end
end