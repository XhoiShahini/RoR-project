class Api::V1::MeetingsController < Api::BaseController
  def index
    @meetings = current_user.meetings.limit(3).order('created_at desc')
    render json: @meetings
  end

  def create
    participant = RemoteService.create_from_json(current_user, params)
    url = meeting_participant_sign_in_url(participant.meeting, participant)
    render json: {sign_url: url}
  end
end
