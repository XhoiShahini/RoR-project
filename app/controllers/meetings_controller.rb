class MeetingsController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting, except: [:index, :new, :create]
  before_action :cannot_modify_completed!, only: [:edit, :update, :destroy]
  before_action :require_current_account_admin, except: [:index, :show]

  # GET /meetings
  def index
    @q = current_account.meetings.ransack(params[:q])
    @meetings = @q.result(distinct: true)
    @pagy, @meetings = pagy(@meetings.sort_by_params(params[:sort], sort_direction))

    # We explicitly load the records to avoid triggering multiple DB calls in the views when checking if records exist and iterating over them.
    @meetings.load
  end

  # GET /meetings/new
  def new
    @meeting = Meeting.new
  end

  # POST /meetings
  def create
    @meeting = Meeting.new(meeting_params)

    if @meeting.save
      @meeting.meeting_members.create(memberable: current_user, must_sign: true)
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
  end

  # PATCH/PUT /meetings/:id
  def update
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
    params.require(:meeting).permit(:title, :starts_at, :host_id)
  end
end
