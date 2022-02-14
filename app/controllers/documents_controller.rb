require 'faraday'

class DocumentsController < ApplicationController
  include MeetingsHelper
  before_action :set_meeting
  before_action :set_document, except: [:index, :tabs, :new, :create]
  before_action :set_signature, only: [:new_signature, :sign, :otp, :verify_otp, :otp_verified, :otp_failed, :mark_as_read]
  before_action :require_meeting_member!
  before_action :cannot_modify_signed!, only: [:edit, :update, :destroy]
  before_action :require_current_account_admin, only: [:new, :create, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:update]

  # GET /meetings/:meeting_id/documents
  def index
    @host = current_account_admin?
    @documents = @meeting.documents
  end

  # GET /meetings/:meeting_id/documents/tabs
  def tabs
    @host = current_account_admin?
    @documents = @meeting.documents
  end

  # GET /meetings/:meeting_id/documents/new
  def new
    @document = @meeting.documents.new
  end

  # POST /meetings/:id/documents
  def create
    @document = @meeting.documents.new(document_params)
    @document.created_by = current_user

    if @document.save
      redirect_to new_meeting_document_path(@meeting), notice: t("documents.notice.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /meetings/:meeting_id/documents/:id
  def show
    respond_to do |format|
      format.html {
        @host = current_account_admin?
      }
      format.json { render json: @document, status: :ok }
    end
  end

  # GET /meetings/:meeting_id/documents/:id/pdf
  def pdf
    stream_document_file disposition: "inline"
  end

  # POST /meetings/:meeting_id/documents/:id/xfdf
  def xfdf
    conn = Faraday.new(url: ENV['PDFJS_EXPRESS_URL']) do |f|
      f.request :multipart
      f.request :url_encoded
      f.adapter :net_http
    end

    body = xfdf_params
    body[:license] = ENV['PDFJS_EXPRESS_LICENSE']

    # FIXME:
    body[:file] = xfdf_params[:file].tempfile.read

    puts body

    response = conn.post() do |req|
      req.body = body.to_json
    end

    puts JSON.parse(response.body)
    render json: response.body, status: :ok
  end

  # GET /meetings/:meeting_id/documents/:id/download
  def download
    stream_document_file disposition: "attachment"
  end

  # GET /meetings/:meeting_id/documents/:id/edit
  def edit
  end

  # PATCH/PUT /meetings/:meeting_id/documents/:id
  def update
    result = @document.update(document_params)

    respond_to do |format|
      format.html { redirect_to @meeting, notice: t("documents.notice.update") }
      format.json { render json: @document, status: :ok }
    end
  end

  # GET /meetings/:meeting_id/documents/:id/new_signature
  def new_signature
    redirect_to cannot_sign_meeting_document_path(@meeting, @document, reason: "not_yet_verified") and return unless @meeting.signing?
    redirect_to cannot_sign_meeting_document_path(@meeting, @document, reason: "require_read") and return if @signature.document.require_read? && @meeting_member.must_sign && !@signature.document_read
    redirect_to sign_meeting_document_path(@meeting, @document) and return if @signature.signed_at.present?
    @memberable = current_user || current_participant
    render layout: false
  end

  # GET /meetings/:meeting_id/documents/:id/sign
  def sign
    unless @signature.signed_at.present?
      @signature.sign! ip: request.remote_ip
    end
    render layout: false
  end

  def cannot_sign
    @reason = params[:reason]
    render layout: false
  end

  # GET /meetings/:meeting_id/documents/:id/otp
  def otp
    @signature.sms_verification.destroy! if @signature.sms_verification.present?
    @signature.sms_verification = SmsVerification.create(sms_verifiable: @signature, phone_number: @meeting_member.memberable.phone_number)
    render layout: false
  end

  # POST /meetings/:meeting_id/documents/:id/verify_otp
  def verify_otp
    @signature.sms_verification.verify_code! params[:code]
    if @signature.sms_verification.verified?
      redirect_to otp_verified_meeting_document_path(@meeting, @document)
    else
      redirect_to otp_failed_meeting_document_path(@meeting, @document), notice: @signature.sms_verification.error
    end
  end

  # GET /meetings/:meeting_id/documents/:id/otp_verified
  def otp_verified
  end

  def otp_failed
  end

  def mark_as_read
    @signature.update(document_read: true)
    render plain: ""
  end

  # DELETE /meetings/meeting_:id/documents/:id
  def destroy
    @document.destroy
    redirect_to meeting_documents_path(@meeting), notice: t("documents.notice.destroy")
  end

  # GET /meetings/:meeting_id/documents/:id/signatures
  def signatures
  end

  private

  def stream_document_file(disposition:)
    response.headers["Content-Type"] = @document.file.content_type
    response.headers["Content-Disposition"] = "#{disposition};"
    response.headers["Content-Length"] = @document.file.byte_size
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"

    @document.file.download do |chunk|
      response.stream.write(chunk)
    end
  ensure
    response.stream.close
  end

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def set_document
    @document = Document.find(params[:id])
  end

  def set_signature
    @meeting_member = @meeting.meeting_members.find_by(memberable: current_user || current_participant)
    @signature = @document.signatures.find_by(meeting_member: @meeting_member)
  end

  def document_params
    params.require(:document).permit(:title, :file, :read_only, :require_read, :signature_fields => [:version, :fields => {}])
  end

  def xfdf_params
    params.require(:pdf).permit(:xfdf, :file)
  end

  def cannot_modify_signed!
    if @document.incomplete? || @document.finalized?
      redirect_to @meeting, alert: t("documents.notice.cannot_be_modified")
    end
  end
end
