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

  # POST perform_action
  def perform_action
    if @meeting_member.memberable.is_a? User
      # for now we do not have "real" controls
      case params[:action]
      when 'moderate':
      end
    end
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end
end