class Meetings::RoomController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting
  before_action :require_meeting_member!
  # GET /meetings/:meeting_id/room
  def show
  end

  # GET /meetings/:meeting_id/room/pre_meeting
  def pre_meeting
    @id_attached = @meeting_member.memberable.identification.attached?
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end
end