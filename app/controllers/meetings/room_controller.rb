class Meetings::RoomController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting
  before_action :require_meeting_member!
  # GET /meetings/:meeting_id/room
  def show
    redirect_to post_meeting_meeting_room_path(@meeting) if @meeting.completed?
    if @meeting_member.is_moderator? && !@meeting.incomplete?
      @meeting.start!
    end
  end

  # GET /meetings/:meeting_id/room/pre_meeting
  def pre_meeting
    @id_attached = @meeting_member.memberable.identification.attached?
  end

  def post_meeting
    if @meeting_member.is_moderator? && !@meeting.completed?
      @meeting.complete!
    elsif !@meeting.completed?
      redirect_to meeting_room_path(@meeting)
    end
  end

  # POST perform_action
  def perform_action
    if @meeting_member.is_moderator?
      # for now we do not have "real" controls
      case params[:command]
      when 'audio'
        
      end
    end
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end
end