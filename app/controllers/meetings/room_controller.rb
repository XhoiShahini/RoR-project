class Meetings::RoomController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting
  before_action :require_meeting_member!
  skip_before_action :verify_authenticity_token, only: :perform_action
  # GET /meetings/:meeting_id/room
  def show
    redirect_to post_meeting_meeting_room_path(@meeting) and return if @meeting.completed?
    redirect_to pre_meeting_meeting_room_path(@meeting)
  end

  # PATCH/PUT /meetings/:meeting_id/room
  def update
    redirect_to post_meeting_meeting_room_path(@meeting) and return if @meeting.completed?
    if @meeting_member.is_moderator? && @meeting.created?
      @meeting.start!
    end
    # @meeting_member.reset_media!
    @token = SignalwireService.request_token(@meeting.signed_room_id, @meeting_member.signed_member_id)
    render "meetings/room/show"
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
    # for now we do not have "real" controls
    memberable = current_user || current_participant
    mm = MeetingMember.where(signed_member_id: params[:member_id], memberable: memberable).first

    if mm
      case params[:command]
      when 'toggle_audio'
        mm.toggle_audio(params[:value])
      when 'toggle_video'
        mm.toggle_video(params[:value])
      end
    end
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end
end