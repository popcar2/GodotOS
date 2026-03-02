extends AudioStreamPlayer2D

var generator: AudioStreamGenerator
var generator_playback: AudioStreamGeneratorPlayback

func _ready() -> void:
	generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.1
	stream = generator
	play()
	generator_playback = get_stream_playback()

func play_beep(frequency: float, duration: float = 0.1) -> void:
	if not generator_playback:
		return

	var sample_rate: float = generator.mix_rate
	var samples: int = int(sample_rate * duration)
	for i in range(samples):
		var t: float = float(i) / sample_rate
		var value: float = 0.0
		if fmod(t * frequency, 1.0) < 0.5:
			value = 1.0
		else:
			value = -1.0
		generator_playback.push_frame(Vector2(value, value))

func play_coin() -> void:
	play_beep(8000, 0.1)
	play_beep(2000, 0.1)

func play_death() -> void:
	play_beep(220, 0.3)
