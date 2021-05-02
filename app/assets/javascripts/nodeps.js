var server = "wss://janus-01.agreelivevideo.com/wsjanus";
var janus = null;
var sfutest = null;
var opaqueId = "videoroomtest-"+Janus.randomString(12);
var myId = "member-"+Janus.randomString(12);
var username = "foobar";
var useAudio = true;
var myroom = "mytestroom";
var userToken = "a1b2c3d4";
var feeds = [];

function ready(callback) {
  if (document.readyState != 'loading') {
    callback();
  } else if (document.addEventListener) {
    document.addEventListener('DOMContentLoaded', callback);
  } else {
    document.attachEvent('onreadystatechange', function() {
      if (document.readyState != 'loading') {
        callback();
      }
    });
  }
}


//call this as the entry point

function joinRoom() {
  var register = {
    request: "join",
    room: myroom,
    ptype: "publisher",
    id: myId,
    display: username,
    token: userToken
  };
  sfutest.send({ message: register });
}

function tryDataChannel() {
  sfutest.data({text: 'bar'})
}

function publishOwnFeed() {
	// Publish our stream
	sfutest.createOffer(
		{
			// Add data:true here if you want to publish datachannels as well
			media: { audioRecv: false, videoRecv: false, audioSend: true, videoSend: true, data: true },	// Publishers are sendonly
			success: function(jsep) {
				Janus.debug("Got publisher SDP!", jsep);
				var publish = { request: "configure", audio: true, video: true };
				sfutest.send({ message: publish, jsep: jsep });
			},
			error: function(error) {
				Janus.error("WebRTC error:", error);
			}
		});
}

function unpublishOwnFeed() {
	// Unpublish our stream
	var unpublish = { request: "unpublish" };
	sfutest.send({ message: unpublish });
}

function newRemoteFeed(id, display, audio, video) {
	// A new feed has been published, create a new plugin handle and attach to it as a subscriber
	var remoteFeed = null;
	janus.attach(
		{
			plugin: "janus.plugin.videoroom",
			opaqueId: opaqueId,
			success: function(pluginHandle) {
				remoteFeed = pluginHandle;
				remoteFeed.simulcastStarted = false;
				Janus.log("Plugin attached! (" + remoteFeed.getPlugin() + ", id=" + remoteFeed.getId() + ")");
				Janus.log("  -- This is a subscriber");
				// We wait for the plugin to send us an offer
				var subscribe = {
					request: "join",
					room: myroom,
					ptype: "subscriber",
					feed: id,
					private_id: mypvtid
				};
				// In case you don't want to receive audio, video or data, even if the
				// publisher is sending them, set the 'offer_audio', 'offer_video' or
				// 'offer_data' properties to false (they're true by default), e.g.:
				// 		subscribe["offer_video"] = false;
				// For example, if the publisher is VP8 and this is Safari, let's avoid video
				if(Janus.webRTCAdapter.browserDetails.browser === "safari" &&
						(video === "vp9" || (video === "vp8" && !Janus.safariVp8))) {
					if(video)
						video = video.toUpperCase()
					toastr.warning("Publisher is using " + video + ", but Safari doesn't support it: disabling video");
					subscribe["offer_video"] = false;
				}
				remoteFeed.videoCodec = video;
				remoteFeed.send({ message: subscribe });
			},
			error: function(error) {
				Janus.error("  -- Error attaching plugin...", error);
				console.log("Error attaching plugin... " + error);
			},
      ondata: function(data) {
				console.log("Data received: ", data);
			},
			onmessage: function(msg, jsep) {
				Janus.debug(" ::: Got a message (subscriber) :::", msg);
				var event = msg["videoroom"];
				Janus.debug("Event: " + event);
				if(msg["error"]) {
					console.log(msg["error"]);
				} else if(event) {
					if(event === "attached") {
						// Subscriber created and attached
						for(var i=1;i<6;i++) {
							if(!feeds[i]) {
								feeds[i] = remoteFeed;
								remoteFeed.rfindex = i;
								break;
							}
						}
						remoteFeed.rfid = msg["id"];
						remoteFeed.rfdisplay = msg["display"];
						Janus.log("Successfully attached to feed " + remoteFeed.rfid + " (" + remoteFeed.rfdisplay + ") in room " + msg["room"]);
					} else if(event === "event") {
						// Check if we got a simulcast-related event from this publisher
						var substream = msg["substream"];
						var temporal = msg["temporal"];
						if((substream !== null && substream !== undefined) || (temporal !== null && temporal !== undefined)) {
							if(!remoteFeed.simulcastStarted) {
								remoteFeed.simulcastStarted = true;
								// Add some new buttons
								addSimulcastButtons(remoteFeed.rfindex, remoteFeed.videoCodec === "vp8" || remoteFeed.videoCodec === "h264");
							}
							// We just received notice that there's been a switch, update the buttons
							updateSimulcastButtons(remoteFeed.rfindex, substream, temporal);
						}
					} else {
						// What has just happened?
					}
				}
				if(jsep) {
					Janus.debug("Handling SDP as well...", jsep);
					// Answer and attach
					remoteFeed.createAnswer(
						{
							jsep: jsep,
							// Add data:true here if you want to subscribe to datachannels as well
							// (obviously only works if the publisher offered them in the first place)
							media: { audioSend: false, videoSend: false, data: true },	// We want recvonly audio/video
							success: function(jsep) {
								Janus.debug("Got SDP!", jsep);
								var body = { request: "start", room: myroom };
								remoteFeed.send({ message: body, jsep: jsep });
							},
							error: function(error) {
								Janus.error("WebRTC error:", error);
								console.log("WebRTC error... " + error.message);
							}
						});
				}
			},
			iceState: function(state) {
				Janus.log("ICE state of this WebRTC PeerConnection (feed #" + remoteFeed.rfindex + ") changed to " + state);
			},
			webrtcState: function(on) {
				Janus.log("Janus says this WebRTC PeerConnection (feed #" + remoteFeed.rfindex + ") is " + (on ? "up" : "down") + " now");
			},
			onlocalstream: function(stream) {
				// The subscriber stream is recvonly, we don't expect anything here
			},
			onremotestream: function(stream) {
				Janus.debug("Remote feed #" + remoteFeed.rfindex + ", stream:", stream);
				Janus.attachMediaStream(document.getElementById('remotevideo'+remoteFeed.rfindex), stream);
			},
			oncleanup: function() {
				Janus.log(" ::: Got a cleanup notification (remote feed " + id + ") :::");
			}
		});
}

ready(async function() {
  Janus.init({debug: "all", callback: function() {
    if(!Janus.isWebrtcSupported()) {
      console.log("No WebRTC support... ");
      return;
    }

    janus = new Janus(
      {
        server: server,
        token: userToken,
        success: function() {
          // Attach to VideoRoom plugin
          janus.attach(
            {
              plugin: "janus.plugin.videoroom",
              opaqueId: opaqueId,
              success: function(pluginHandle) {
                sfutest = pluginHandle;
                Janus.log("Plugin attached! (" + sfutest.getPlugin() + ", id=" + sfutest.getId() + ")");
              },
              error: function(error) {
                Janus.error("  -- Error attaching plugin...", error);
                console.log("Error attaching plugin... " + error);
              },
              consentDialog: function(on) {
                
              },
              iceState: function(state) {
                Janus.log("ICE state changed to " + state);
              },
              mediaState: function(medium, on) {
                Janus.log("Janus " + (on ? "started" : "stopped") + " receiving our " + medium);
              },
              webrtcState: function(on) {
                Janus.log("Janus says our WebRTC PeerConnection is " + (on ? "up" : "down") + " now");
              },
              onmessage: function(msg, jsep) {
                Janus.debug(" ::: Got a message (publisher) :::", msg);
                var event = msg["videoroom"];
                Janus.debug("Event: " + event);
                if(event) {
                  if(event === "joined") {
                    // Publisher/manager created, negotiate WebRTC and attach to existing feeds, if any
                    myid = msg["id"];
                    mypvtid = msg["private_id"];
                    Janus.log("Successfully joined room " + msg["room"] + " with ID " + myid);
                    publishOwnFeed(true);
                    // Any new feed to attach to?
                    if(msg["publishers"]) {
                      var list = msg["publishers"];
                      Janus.debug("Got a list of available publishers/feeds:", list);
                      for(var f in list) {
                        var id = list[f]["id"];
                        var display = list[f]["display"];
                        var audio = list[f]["audio_codec"];
                        var video = list[f]["video_codec"];
                        Janus.debug("  >> [" + id + "] " + display + " (audio: " + audio + ", video: " + video + ")");
                        newRemoteFeed(id, display, audio, video);
                      }
                    }
                  } else if(event === "destroyed") {
                    // The room has been destroyed
                    Janus.warn("The room has been destroyed!");
                      window.location.reload();
                  } else if(event === "event") {
                    // Any new feed to attach to?
                    if(msg["publishers"]) {
                      var list = msg["publishers"];
                      Janus.debug("Got a list of available publishers/feeds:", list);
                      for(var f in list) {
                        var id = list[f]["id"];
                        var display = list[f]["display"];
                        var audio = list[f]["audio_codec"];
                        var video = list[f]["video_codec"];
                        Janus.debug("  >> [" + id + "] " + display + " (audio: " + audio + ", video: " + video + ")");
                        newRemoteFeed(id, display, audio, video);
                      }
                    } else if(msg["leaving"]) {
                      // One of the publishers has gone away?
                      var leaving = msg["leaving"];
                      Janus.log("Publisher left: " + leaving);
                      var remoteFeed = null;
                      for(var i=1; i<6; i++) {
                        if(feeds[i] && feeds[i].rfid == leaving) {
                          remoteFeed = feeds[i];
                          break;
                        }
                      }
                      if(remoteFeed != null) {
                        Janus.debug("Feed " + remoteFeed.rfid + " (" + remoteFeed.rfdisplay + ") has left the room, detaching");
                        feeds[remoteFeed.rfindex] = null;
                        remoteFeed.detach();
                      }
                    } else if(msg["unpublished"]) {
                      // One of the publishers has unpublished?
                      var unpublished = msg["unpublished"];
                      Janus.log("Publisher left: " + unpublished);
                      if(unpublished === 'ok') {
                        // That's us
                        sfutest.hangup();
                        return;
                      }
                      var remoteFeed = null;
                      for(var i=1; i<6; i++) {
                        if(feeds[i] && feeds[i].rfid == unpublished) {
                          remoteFeed = feeds[i];
                          break;
                        }
                      }
                      if(remoteFeed != null) {
                        Janus.debug("Feed " + remoteFeed.rfid + " (" + remoteFeed.rfdisplay + ") has left the room, detaching");
                        feeds[remoteFeed.rfindex] = null;
                        remoteFeed.detach();
                      }
                    } else if(msg["error"]) {
                      if(msg["error_code"] === 426) {
                        // This is a "no such room" error: give a more meaningful description
                        console.log("room " + myroom + " does not exist...");
                      } else {
                        console.log(msg["error"]);
                      }
                    }
                  }
                }
                if(jsep) {
                  Janus.debug("Handling SDP as well...", jsep);
                  sfutest.handleRemoteJsep({ jsep: jsep });
                  // Check if any of the media we wanted to publish has
                  // been rejected (e.g., wrong or unsupported codec)
                  var audio = msg["audio_codec"];
                  if(mystream && mystream.getAudioTracks() && mystream.getAudioTracks().length > 0 && !audio) {
                    // Audio has been rejected
                    console.log("Our audio stream has been rejected, viewers won't hear us");
                  }
                  var video = msg["video_codec"];
                  if(mystream && mystream.getVideoTracks() && mystream.getVideoTracks().length > 0 && !video) {
                    // Video has been rejected
                    console.log("Our video stream has been rejected, viewers won't see us");
                  }
                }
              },
              onlocalstream: function(stream) {
                Janus.debug(" ::: Got a local stream :::", stream);
                mystream = stream;
                Janus.attachMediaStream(document.getElementById('myvideo'), stream);
                document.getElementById("myvideo").muted = "muted";
                if(sfutest.webrtcStuff.pc.iceConnectionState !== "completed" &&
                    sfutest.webrtcStuff.pc.iceConnectionState !== "connected") {
                  console.log("Publishing started");
                }
                var videoTracks = stream.getVideoTracks();
                if(!videoTracks || videoTracks.length === 0) {
                  // No webcam
                  console.log("no webcam")
                } else {
                  console.log("we have a webcam")
                }
              },
              onremotestream: function(stream) {
                // The publisher stream is sendonly, we don't expect anything here
              },
              oncleanup: function() {
                Janus.log(" ::: Got a cleanup notification: we are unpublished now :::");
                mystream = null;
              }
            });
        },
        error: function(error) {
          Janus.error(error);
          console.log('FATAL ERROR', error)
          // window.location.reload();
        },
        destroyed: function() {
          window.location.reload();
        }
      });
  }});
});