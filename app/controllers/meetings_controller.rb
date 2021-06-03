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
    @meeting = Meeting.new
  end

  # POST /meetings
  def create
    meeting_member_params = { company_id: params[:company_id], must_sign: params[:must_sign] } rescue {}
    logger.info meeting_member_params
    @meeting = Meeting.new(meeting_params)

    if @meeting.save && @meeting.meeting_members.create(meeting_member_params.merge({ memberable: current_user }))
      redirect_to @meeting, notice: t("meetings.notice.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /meetings/:id
  def show
    require_meeting_member!
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
    params.require(:meeting).permit(:title, :starts_at, :host_id, :account_id)
  end
end
