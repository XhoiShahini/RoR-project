class Users::IdUploadsController < ApplicationController
  before_action :authenticate_user!

  # GET /users/id_upload/new
  def new
  end

  # POST /users/id_upload
  def create
    if current_user.update(id_upload_params)
      redirect_to new_user_id_upload_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/id_upload
  def show
  end

  def destroy
    current_user.identification.destroy
    MeetingMembersChannel.broadcast_to @meeting, type: "update"
    redirect_to new_user_id_upload_path
  end

  private

  def id_upload_params
    params.require(:user).permit(:identification)
  end
end