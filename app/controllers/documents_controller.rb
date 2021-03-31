class DocumentsController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting
  before_aciton :set_document, except: [:index, :new, :create]
  before_action :require_meeting_member!
  before_action :cannot_modify_signed!, only: [:edit, :update, :destroy]
  before_action :require_current_account_admin, except: [:index, :show]

  # GET /meetings/:meeting_id/documents
  def index
    @documents = @meeting.documents
  end

  # GET /meetings/:meeting_id/documents/new
  def new
    @document = @meeting.documents.new
  end

  # POST /meetings/:id/documents
  def create
    @document = @meeting.documents.new(document_params)

    if @document.save
      redirect_to @meeting, notice: t("documents.notice.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /meetings/:meeting_id/documents/:id
  def show
  end

  # GET /meetings/:meeting_id/documents/:id/edit
  def edit
  end

  # PATCH/PUT /meetings/:meeting_id/documents/:id
  def update
    if @document.update(document_params)
      redirect_to @meeting, notice: t("documents.notice.update")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /meetings/meeting_:id/documents/:id
  def destroy
    @meeting.destroy
    redirect_to meetings_url, notice: t("documents.notice.destroy")
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:title, :file, :read_only, :require_read)
  end

  def cannot_modify_signed!
    if @document.incomplete? || @document.finalized?
      redirect_to @meeting, alert: t("documents.notice.cannot_be_modified")
    end
  end
end