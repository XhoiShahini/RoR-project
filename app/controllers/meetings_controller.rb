class MeetingsController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting, except: [:index, :new, :create]
  before_action :cannot_modify_completed!, only: [:edit, :update, :destroy]
  before_action :require_current_account_admin, except: [:index, :show]

  # GET /meetings
  def index
    if !current_user && current_participant
      redirect_to current_participant.meeting and return
    end
    @q = current_account.meetings.ransack(params[:q])
    @meetings = @q.result(distinct: true)
    @pagy, @meetings = pagy(@meetings.sort_by_params(params[:sort], sort_direction))

    # We explicitly load the records to avoid triggering multiple DB calls in the views when checking if records exist and iterating over them.
    @meetings.load
  end

  # GET /meetings/new
  def new
    @companies = current_account.companies
    @meeting = Meeting.new(use_video: false)
  end

  # POST /meetings
  def create
    meeting_member_params = { company_id: params[:company_id], must_sign: params[:must_sign] } rescue {}
    @meeting = Meeting.new(meeting_params)
    @meeting.is_async = @meeting.use_video == "0"

    if @meeting.save && @meeting.meeting_members.create(meeting_member_params.merge({ memberable: current_user }))
      redirect_to @meeting, notice: t("meetings.notice.create")
    else
      @companies = current_account.companies
      render :new, status: :unprocessable_entity
    end
  end

  # GET /meetings/:id
  def show
    require_meeting_member!

    @recordings = []

    if @meeting.host == current_user
      @recordings = SignalwireService.get_recordings_for_room(@meeting.signed_room_id).map do |rec|
        {
          id: rec['id'],
          started_at: DateTime.parse(rec['started_at']),
          uri: rec['uri'],
          duration: Time.at(rec['duration']).utc.strftime('%H h %M m %S s')
        }
      end
      puts 'afafafafa'
      puts @recordings
    end
  end

  # GET /meetings/:id/edit
  def edit
    @host_member = @meeting.meeting_members.find_by(memberable: @meeting.host)
    @companies = current_account.companies
  end

  # PATCH/PUT /meetings/:id
  def update
    meeting_member_params = { company_id: params[:company_id], must_sign: params[:must_sign] } rescue {}
    if meeting_member_params.present?
      host = @meeting.meeting_members.find_by(memberable: @meeting.host)
      host.update(meeting_member_params)
    end
    if @meeting.update(meeting_params)
      redirect_to @meeting, notice: t("meetings.notice.update")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def allow_signatures
    @meeting.allow_signatures!
    MeetingEventsChannel.broadcast_to @meeting, type: "start_signing"
  end

  # DELETE /meetings/:id
  def destroy
    @meeting.destroy
    redirect_to meetings_url, notice: t("meetings.notice.destroy")
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:id])
  end

  def meeting_params
    params.require(:meeting).permit(:title, :starts_at, :host_id, :account_id, :is_async, :use_video)
  end
end
