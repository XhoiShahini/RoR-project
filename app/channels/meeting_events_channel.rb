class MeetingEventsChannel < ApplicationCable::Channel
  def subscribed
    stream_for Meeting.find(params[:meeting_id])
  end

  def unsubscribed
    stop_all_streams
  end
end
