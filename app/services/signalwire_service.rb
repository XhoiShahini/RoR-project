require 'faraday'

class SignalwireService
  def self.api_request(payload, endpoint, method = :post)
    conn = Faraday.new(url: "https://#{ENV['SIGNALWIRE_SPACE']}/api/video/#{endpoint}")
    conn.basic_auth(ENV['SIGNALWIRE_PROJECT_KEY'], ENV['SIGNALWIRE_TOKEN'])
  
    if method == :post
      response = conn.post() do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = payload.to_json
      end
    elsif method == :get
      response = conn.get() do |req|
        req.headers['Content-Type'] = 'application/json'
      end
    end
  
    JSON.parse(response.body)
  end
  
  # Request a token with simple capabilities
  def self.request_token(room, user)
    payload = {
      room_name: room,
      user_name: user,
      auto_create_room: true,
      permissions: [
        "room.self.audio_mute",
        "room.self.audio_unmute",
        "room.self.video_mute",
        "room.self.video_unmute",
        "room.recording"
      ]
    }
    Rails.logger.info payload
    result = api_request(payload, 'room_tokens')
    result['token']
  end

  def self.get_recordings_for_room(room_name)
    room = api_request({}, "room_sessions?room_name=#{room_name}", :get)
    recordings = []
    room['data'].each do |session|
      recs = api_request({}, "room_sessions/#{session['id']}/recordings", :get)
      recordings += recs['data'].filter {|r| r['status'] == 'completed'}
    end
    recordings
  end
end