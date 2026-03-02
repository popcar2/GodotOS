extends AudioStreamPlayer2D

var generator: AudioStreamGenerator
var generator_playback: AudioStreamGeneratorPlayback
var is_playing_song: bool = false

func _ready() -> void:
	generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.1
	stream = generator

func start_song() -> void:
	if not is_playing_song:
		play()
		generator_playback = get_stream_playback()
		is_playing_song = true
		giorno()

func stop_song() -> void:
	if is_playing_song:
		is_playing_song = false
		stop()

func generate_loop() -> void:
	var sample_rate: float = generator.mix_rate
	var notes: Array = [440, 550, 660, 880, 660, 550]
	var duration: float = 0.2

	while is_playing_song:
		for freq: int in notes:
			if not is_playing_song:
				return
			var samples: int = int(sample_rate * duration)
			for i in range(samples):
				var t: float = float(i) / sample_rate
				var value: float = 0.1 if fmod(t * freq, 1.0) < 0.5 else -0.1
				generator_playback.push_frame(Vector2(value, value))
			await get_tree().create_timer(duration).timeout

func giorno() -> void:
	if not is_playing_song:
		play()
		generator_playback = get_stream_playback()
		is_playing_song = true

	var sample_rate: float = generator.mix_rate
	var notes: Array = [440, 523, 587, 659, 784, 880, 659, 587, 523, 440]
	var durations: Array = [0.25, 0.25, 0.25, 0.25, 0.5, 0.5, 0.25, 0.25, 0.25, 0.5]

	while is_playing_song:
		for i in range(notes.size()):
			if not is_playing_song:
				return
			var freq: float = notes[i]
			var duration: float = durations[i]
			var samples: int = int(sample_rate * duration)
			for j in range(samples):
				var t: float = float(j) / sample_rate
				var value: float = 0.1 if fmod(t * freq, 1.0) < 0.5 else -0.1
				generator_playback.push_frame(Vector2(value, value))
			await get_tree().create_timer(duration).timeout
