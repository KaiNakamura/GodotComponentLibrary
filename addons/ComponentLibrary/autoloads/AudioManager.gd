extends Node

func play(audio_stream: AudioStream, volume: float = 0, pitch: float = 1):
	var audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = audio_stream
	audio_stream_player.volume_db = volume
	audio_stream_player.pitch_scale = pitch
	audio_stream_player.play()
	audio_stream_player.connect("finished", audio_stream_player.queue_free)
