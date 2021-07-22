require 'faraday'

class SignalwireService
  def self.api_request(payload, endpoint)
    conn = Faraday.new(url: "https://#{ENV['SIGNALWIRE_SPACE']}/api/video/#{endpoint}")
    conn.basic_auth(ENV['SIGNALWIRE_PROJECT_KEY'], ENV['SIGNALWIRE_TOKEN'])
  
    response = conn.post() do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = payload.to_json
    end
  
    JSON.parse(response.body)
  end
  
  # Request a token with simple capabilities
  def self.request_token(room, user)
    payload = {
      room_name: room,
      user_name: user,
      auto_create_room: true,
      scopes: [
        "room.self.audio_mute",
        "room.self.audio_unmute",
        "room.self.video_mute",
        "room.self.video_unmute"
      ]
    }
    result = api_request(payload, 'room_tokens')
    result['token']
  end
end