class MeetingMembersController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting
  before_action :require_meeting_member!, only: [:index, :show, :identification]
  before_action :require_current_account_admin, except: [:index, :show, :identification]
  before_action :cannot_modify_completed!, except: [:index, :show, :identification]
  before_action :set_member, except: [:index, :new, :create]
  before_action :set_users_for_select, only: [:new, :edit, :create, :update]

  # GET /meetings/:meeting_id/members
  def index
    @host = current_account_admin?
    @meeting_members = @meeting.meeting_members
  end

  # GET /meetings/:meeting_id/members/new
  def new
    @meeting_member = @meeting.meeting_members.new
  end

  # POST /meetings/:meeting_id/members
  def create
    @meeting_member = @meeting.meeting_members.new(meeting_member_params)

    if @meeting_member.save
      redirect_to @meeting, notice: t("meeting_members.notice.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /meetings/:meeting_id/members/:id
  def show
  end

  # GET /meetings/:meeting_id/members/:id/identification
  def identification
    stream_identification_file
  end

  # GET /meetings/:meeting_id/members/:id/edit
  def edit
  end

  # PATCH/PUT /meetings/:meeting_id/members/:id
  def update
    if @meeting_member.update(meeting_member_params)
      redirect_to @meeting, notice: t("meeting_members.notice.update")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /meetings/:meeting_id/members/:id
  def destroy
    if @meeting_member.memberable_type == "Participant"
      @meeting_member.memberable.destroy
    else
      @meeting_member.destroy
    end
    redirect_to @meeting, notice: t("meeting_members.notice.destroy")
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def set_member
    @meeting_member = MeetingMember.find(params[:id])
  end

  def meeting_member_params
    params.require(:meeting_member).permit(:memberable_id, :memberable_type, :must_sign).merge(meeting_id: @meeting.id)
  end

  def set_users_for_select
    user_ids = @meeting.meeting_members.where(memberable_type: "User").map { |mm| mm.memberable_id }
    @users_for_select = @meeting.account.users.where.not(id: user_ids).collect { |u| ["#{u.name} (#{u.email})", u.id]}
  end

  def stream_identification_file
    return unless @meeting_member.memberable.identification.attached?
    response.headers["Content-Type"] = @meeting_member.memberable.identification.content_type
    response.headers["Content-Disposition"] = "inline;"

    @meeting_member.memberable.identification.download do |chunk|
      response.stream.write(chunk)
    end
  ensure
    response.stream.close
  end
end