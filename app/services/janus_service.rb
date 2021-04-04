require 'securerandom'
require 'net/http'
require 'uri'
require 'json'

class JanusService
  class << self
    def create_room(meeting)
      payload = {
        request:"create",
        admin_key: meeting.server.admin_key,
        room: meeting.signed_room_id,
        secret: meeting.janus_secret,
        # below are the room settings
        publishers: 30,
        audiolevel_event: true,
        audio_active_packets: 50,
        audio_level_average: 10
     }

     send_room_request(meeting.server, payload)
    end

    def add_token_to_room(meeting_member)
      payload = {
        request:"allowed",
        room: meeting_member.meeting.signed_room_id,
        secret: meeting_member.meeting.janus_secret,
        action: 'add',
        "allowed": [
          meeting_member.janus_token
        ]
      }

      send_room_request(meeting_member.server, payload)
    end

    def destroy_room(meeting)
      payload = {
        request:"destroy",
        room: meeting.signed_room_id,
        secret: meeting.janus_secret
      }

      send_room_request(meeting.server, payload)
    end

    # This does NOT prevent the user from entering again
    # Remove token first, then kick them
    def kick_member(meeting_member)
      payload = {
        request:"kick",
        room: meeting_member.meeting.signed_room_id,
        secret: meeting_member.meeting.janus_secret,
        id: meeting_member.signed_member_id
      }

      send_room_request(meeting_member.server, payload)
    end

    def moderate_member(meeting_member, change_audio: false, audio_state: true, change_video: false, video_state: true)
      payload = {
        request:"moderate",
        room: meeting_member.meeting.signed_room_id,
        secret: meeting_member.meeting.janus_secret,
        id: meeting_member.signed_member_id
      }

      payload[:audio] = audio_state if change_audio
      payload[:video] = video_state if change_video

      send_room_request(meeting_member.server, payload)
    end

    def list_rooms(server)
      payload = {
        request: "list"
      }

      send_room_request(server, payload)
    end

    # this just creates the token, it needs to be added to a room to work
    def add_token(meeting_member)
      payload = {
        janus: "add_token",
        token: meeting_member.janus_token,
        transaction: generate_transaction_id,
        admin_secret: meeting_member.server.admin_secret
      }

      post_to_server(meeting_member.server, payload)
    end

    def remove_token(meeting_member)
      payload = {
        janus: "remove_token",
        token: meeting_member.janus_token,
        transaction: generate_transaction_id,
        admin_secret: meeting_member.server.admin_secret
      }

      post_to_server(meeting_member.server, payload)
    end

    # "private"

    def send_room_request(server, payload)
      req = {
        janus: "message_plugin",
        transaction: generate_transaction_id,
        admin_secret: server.admin_secret,
        plugin: "janus.plugin.videoroom",
        request: payload
      }

      post_to_server(server, req)
    end

    def post_to_server(server, req)
      uri = URI.parse("https://#{server.domain}/#{ENV.fetch('JANUS_HTTP_PATH', 'httpjanus')}")

      header = {'Content-Type': 'text/json'}
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = req.to_json
      response = http.request(request)
      response.body
    end

    def generate_transaction_id
      SecureRandom.hex(16)
    end
  end
end