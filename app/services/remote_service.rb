class RemoteService
  def self.create_from_json(current_user, json)
    # create meeting
    meeting = Meeting.new(
      is_api: true,
      is_async: true,
      host: current_user,
      title: 'Firma Documenti',
      account: current_user.accounts.first
    )
    
    meeting.save
    #create meeting member or it doesn't work
    meeting.meeting_members.create( memberable: current_user, must_sign: false)
    # create document
    document = meeting.documents.create(created_by: current_user, title: 'Firma', read_only: false)
    # attach document to meeting
    download_and_attach(json['document_url'], document)
    document.save
    # create participant (no invite)
    participant_params = {
      first_name: json['first_name'],
      last_name: json['last_name'],
      email: json['email'],
      phone_number: json['phone_number'],
      meeting_member_attributes: {
        must_sign: true,
        meeting_id: meeting.id
      }
    }
    participant = meeting.account.participants.new(participant_params)
    participant.save

    return participant
  end

  def self.download_and_attach(file_url, document)
    url = URI(file_url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true if url.scheme == 'https'

    request = Net::HTTP::Get.new(url)
    response = https.request(request)
    document.file.attach(io: StringIO.new(response.body) , filename: "#{document.id}.pdf")
  end
end