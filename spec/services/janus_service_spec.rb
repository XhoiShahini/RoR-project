require 'rails_helper'

RSpec.describe JanusService do
  let (:server) { create :server, domain: "demovideoagree.com", admin_secret: "betcha", admin_key: "doncha" }
  let (:meeting) { create :meeting, server: server } # this should actually be set by the logic
  let (:meeting_member) { create :meeting_member, meeting: meeting, memberable: meeting.host }

  let(:static_transaction_id) { '123abc456def789' }
  subject { described_class }

  before do
    allow(subject).to receive(:generate_transaction_id).and_return(static_transaction_id)
  end

  it "creates a room" do
    expected_json = {
      janus: "message_plugin",
      transaction: static_transaction_id,
      admin_secret: server.admin_secret,
      plugin: "janus.plugin.videoroom",
      request: {
        request:"create",
        admin_key: server.admin_key,
        room: meeting.signed_room_id,
        secret: meeting.janus_secret,
        publishers: 30,
        audiolevel_event: true,
        audio_active_packets: 50,
        audio_level_average: 10
      }
    }

    stub_request(:post, "https://#{server.domain}/httpjanus").
      with({
        body: expected_json.to_json
      }).to_return(status: 200, body: "", headers: {})

    subject.create_room(meeting)
  end

  it "adds a token to an existing room" do
    expected_json = {
      janus: "message_plugin",
      transaction: static_transaction_id,
      admin_secret: server.admin_secret,
      plugin: "janus.plugin.videoroom",
      request: {
        request:"allowed",
        room: meeting.signed_room_id,
        secret: meeting.janus_secret,
        action: 'add',
        "allowed": [
          meeting_member.janus_token
        ]
      }
    }

    stub_request(:post, "https://#{server.domain}/httpjanus").
      with({
        body: expected_json.to_json
      }).to_return(status: 200, body: "", headers: {})

    subject.add_token_to_room(meeting_member)
  end

  it "destroys a room" do
    expected_json = {
      janus: "message_plugin",
      transaction: static_transaction_id,
      admin_secret: server.admin_secret,
      plugin: "janus.plugin.videoroom",
      request: {
        request:"destroy",
        room: meeting.signed_room_id,
        secret: meeting.janus_secret,
      }
    }

    stub_request(:post, "https://#{server.domain}/httpjanus").
      with({
        body: expected_json.to_json
      }).to_return(status: 200, body: "", headers: {})

    subject.destroy_room(meeting)
  end

  it "kicks the user" do
    expected_json = {
      janus: "message_plugin",
      transaction: static_transaction_id,
      admin_secret: server.admin_secret,
      plugin: "janus.plugin.videoroom",
      request: {
        request:"kick",
        room: meeting.signed_room_id,
        secret: meeting.janus_secret,
        id: meeting_member.signed_member_id
      }
    }

    stub_request(:post, "https://#{server.domain}/httpjanus").
      with({
        body: expected_json.to_json
      }).to_return(status: 200, body: "", headers: {})

    subject.kick_member(meeting_member)
  end

  it "moderates the user" do
    expected_json = {
      janus: "message_plugin",
      transaction: static_transaction_id,
      admin_secret: server.admin_secret,
      plugin: "janus.plugin.videoroom",
      request: {
        request:"moderate",
        room: meeting.signed_room_id,
        secret: meeting.janus_secret,
        id: meeting_member.signed_member_id,
        audio: false
      }
    }

    stub_request(:post, "https://#{server.domain}/httpjanus").
      with({
        body: expected_json.to_json
      }).to_return(status: 200, body: "", headers: {})

    subject.moderate_member(meeting_member, change_audio: true, audio_state: false)
  end

  it "lists rooms" do
    stub_request(:post, "https://#{server.domain}/httpjanus").
      with({
        body: "{\"janus\":\"message_plugin\",\"transaction\":\"#{static_transaction_id}\",\"admin_secret\":\"#{server.admin_secret}\",\"plugin\":\"janus.plugin.videoroom\",\"request\":{\"request\":\"list\"}}"
      }).to_return(status: 200, body: "", headers: {})

    subject.list_rooms(server)
  end

  it "creates a new token" do
    expected_json = {
      janus: "add_token",
      token: meeting_member.janus_token,
      transaction: static_transaction_id,
      admin_secret: server.admin_secret
    }

    stub_request(:post, "https://#{server.domain}/httpjanus").
      with({
        body: expected_json.to_json
      }).to_return(status: 200, body: "", headers: {})
    
    subject.add_token(meeting_member)
  end


  it "deletes a token" do
    expected_json = {
      janus: "remove_token",
      token: meeting_member.janus_token,
      transaction: static_transaction_id,
      admin_secret: server.admin_secret
    }

    stub_request(:post, "https://#{server.domain}/httpjanus").
      with({
        body: expected_json.to_json
      }).to_return(status: 200, body: "", headers: {})
    
    subject.remove_token(meeting_member)
  end
end