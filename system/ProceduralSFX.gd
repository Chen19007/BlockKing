extends Node


enum VoiceType { CLICK, HIT, SWING, JUMP, LAND, CHARGE }

class Voice:
	var id: int = 0
	var type: int = 0
	var t: float = 0.0
	var dur: float = 0.1
	var phase: float = 0.0
	var vib_phase: float = 0.0

	var attack: float = 0.002
	var decay: float = 0.08
	var sustain: float = 0.0
	var release: float = 0.08
	var releasing: bool = false
	var release_level: float = 1.0

	var freq0: float = 440.0
	var freq1: float = 440.0
	var pitch_drop: float = 0.0
	var noise: float = 0.0
	var drive: float = 0.0

	var hp_cut: float = 0.0
	var hp_z: float = 0.0

	var lp_cut0: float = 0.0
	var lp_cut1: float = 0.0
	var lp_z: float = 0.0

	var bp_center0: float = 800.0
	var bp_center1: float = 2000.0
	var bp_q: float = 1.0
	var bp_lp_z: float = 0.0
	var bp_hp_z: float = 0.0

	var vib_rate: float = 0.0
	var vib_depth: float = 0.0


@export var mix_rate: int = 44100
@export var buffer_length_sec: float = 0.06
@export var master_gain: float = 0.22
@export var max_voices: int = 16
@export var fill_block_frames: int = 256

var _player: AudioStreamPlayer
var _generator: AudioStreamGenerator
var _playback: AudioStreamGeneratorPlayback
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _voices: Array = []
var _next_voice_id: int = 1
var _charge_voice_id: int = -1


func _ready() -> void:
	_rng.randomize()
	_player = AudioStreamPlayer.new()
	add_child(_player)

	_generator = AudioStreamGenerator.new()
	_generator.mix_rate = mix_rate
	_generator.buffer_length = buffer_length_sec
	_player.stream = _generator
	_player.play()

	_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not _playback:
		push_warning("[ProceduralSFX] failed to get stream playback")
		return
	_fill_generator_buffer()


func _process(_delta: float) -> void:
	_fill_generator_buffer()


func play_click(strength: float = 0.6) -> void:
	var s: float = clampf(strength, 0.0, 1.0)
	var v: Voice = _make_voice(VoiceType.CLICK, 0.05)
	v.freq0 = lerpf(900.0, 1700.0, s) * _jitter(1.0, 0.08)
	v.noise = 0.03
	v.attack = 0.001
	v.decay = 0.04
	v.pitch_drop = 0.04
	_add_voice(v)


func play_hit(strength: float = 0.8) -> void:
	var s: float = clampf(strength, 0.0, 1.0)
	var v: Voice = _make_voice(VoiceType.HIT, lerpf(0.07, 0.12, s))
	v.freq0 = lerpf(140.0, 320.0, s) * _jitter(1.0, 0.10)
	v.freq1 = v.freq0 * 0.6
	v.noise = lerpf(0.16, 0.32, s)
	v.attack = 0.002
	v.decay = lerpf(0.055, 0.10, s)
	v.pitch_drop = lerpf(0.18, 0.42, s)
	v.drive = lerpf(0.10, 0.20, s)
	_add_voice(v)


func play_swing(speed: float = 0.7) -> void:
	var s: float = clampf(speed, 0.0, 1.0)
	var v: Voice = _make_voice(VoiceType.SWING, lerpf(0.10, 0.20, s))
	v.noise = 1.0
	v.attack = 0.010
	v.decay = lerpf(0.09, 0.17, s)
	v.bp_center0 = lerpf(450.0, 850.0, s) * _jitter(1.0, 0.10)
	v.bp_center1 = lerpf(1500.0, 2600.0, s) * _jitter(1.0, 0.10)
	v.bp_q = lerpf(0.8, 1.4, s)
	_add_voice(v)


func play_jump(strength: float = 0.7) -> void:
	var s: float = clampf(strength, 0.0, 1.0)
	var v: Voice = _make_voice(VoiceType.JUMP, lerpf(0.10, 0.15, s))
	v.freq0 = lerpf(260.0, 420.0, s) * _jitter(1.0, 0.08)
	v.freq1 = lerpf(700.0, 980.0, s) * _jitter(1.0, 0.08)
	v.noise = lerpf(0.05, 0.12, s)
	v.attack = 0.006
	v.decay = lerpf(0.09, 0.13, s)
	_add_voice(v)


func play_land(weight: float = 0.8) -> void:
	var w: float = clampf(weight, 0.0, 1.0)
	var v: Voice = _make_voice(VoiceType.LAND, lerpf(0.07, 0.12, w))
	v.freq0 = lerpf(140.0, 70.0, w) * _jitter(1.0, 0.10)
	v.freq1 = v.freq0 * 0.7
	v.noise = lerpf(0.06, 0.16, w)
	v.attack = 0.001
	v.decay = lerpf(0.07, 0.12, w)
	v.pitch_drop = lerpf(0.10, 0.25, w)
	v.hp_cut = 35.0
	_add_voice(v)


func start_charge(level: float = 0.6) -> void:
	if _charge_voice_id != -1:
		return
	var l: float = clampf(level, 0.0, 1.0)
	var v: Voice = _make_voice(VoiceType.CHARGE, 9999.0)
	v.freq0 = lerpf(120.0, 220.0, l)
	v.freq1 = lerpf(240.0, 420.0, l)
	v.attack = 0.06
	v.decay = 0.0
	v.sustain = 1.0
	v.noise = 0.04
	v.vib_rate = 5.0
	v.vib_depth = 0.018
	v.lp_cut0 = 600.0
	v.lp_cut1 = 2200.0
	v.drive = 0.08
	_charge_voice_id = v.id
	_add_voice(v)


func update_charge(level: float) -> void:
	if _charge_voice_id == -1:
		return
	var l: float = clampf(level, 0.0, 1.0)
	for voice_var in _voices:
		var voice: Voice = voice_var as Voice
		if voice and voice.id == _charge_voice_id:
			voice.freq0 = lerpf(110.0, 260.0, l)
			voice.freq1 = lerpf(220.0, 520.0, l)
			voice.lp_cut1 = lerpf(900.0, 4800.0, l)
			voice.drive = lerpf(0.08, 0.18, l)
			return


func stop_charge() -> void:
	if _charge_voice_id == -1:
		return
	for voice_var in _voices:
		var voice: Voice = voice_var as Voice
		if voice and voice.id == _charge_voice_id:
			voice.release = 0.10
			voice.releasing = true
			voice.release_level = maxf(voice.release_level, 1.0)
			break
	_charge_voice_id = -1


func _fill_generator_buffer() -> void:
	if not _playback:
		return
	var available: int = _playback.get_frames_available()
	while available >= fill_block_frames:
		_mix_block(fill_block_frames)
		available -= fill_block_frames


func _make_voice(voice_type: int, dur: float) -> Voice:
	var v: Voice = Voice.new()
	v.id = _next_voice_id
	_next_voice_id += 1
	v.type = voice_type
	v.dur = dur
	return v


func _add_voice(v: Voice) -> void:
	_voices.append(v)
	if _voices.size() > max_voices:
		_voices.pop_front()


func _mix_block(frames: int) -> void:
	if not _playback:
		return
	var dt: float = 1.0 / float(mix_rate)
	for _i in range(frames):
		var sample_value: float = 0.0
		for voice_index in range(_voices.size() - 1, -1, -1):
			var voice: Voice = _voices[voice_index] as Voice
			if not voice:
				_voices.remove_at(voice_index)
				continue
			sample_value += _render_voice(voice, dt)
			if _should_remove_voice(voice):
				_voices.remove_at(voice_index)

		sample_value *= master_gain
		sample_value = _soft_clip(sample_value, 0.32)
		_playback.push_frame(Vector2(sample_value, sample_value))


func _should_remove_voice(v: Voice) -> bool:
	if v.type == VoiceType.CHARGE:
		return v.releasing and v.release_level <= 0.0005
	return v.t >= v.dur


func _render_voice(v: Voice, dt: float) -> float:
	v.t += dt
	var env: float = _envelope(v, dt)

	var progress: float = clampf(v.t / maxf(v.dur, 0.00001), 0.0, 1.0)
	var freq: float = lerpf(v.freq0, v.freq1, progress)
	if v.pitch_drop > 0.0 and v.type != VoiceType.SWING:
		freq *= (1.0 - v.pitch_drop * progress)
	if v.vib_rate > 0.0 and v.vib_depth > 0.0:
		v.vib_phase += TAU * v.vib_rate * dt
		freq *= (1.0 + sin(v.vib_phase) * v.vib_depth)

	var osc: float = 0.0
	match v.type:
		VoiceType.CLICK:
			v.phase += TAU * freq * dt
			osc = signf(sin(v.phase))
		VoiceType.HIT, VoiceType.JUMP, VoiceType.LAND, VoiceType.CHARGE:
			v.phase += TAU * freq * dt
			osc = sin(v.phase)
		VoiceType.SWING:
			osc = 0.0

	var noise_sample: float = _rng.randf_range(-1.0, 1.0)
	var mixed: float = (osc * (1.0 - v.noise) + noise_sample * v.noise) * env

	if v.type == VoiceType.SWING:
		var center: float = lerpf(v.bp_center0, v.bp_center1, progress)
		mixed = _bandpass_approx(v, mixed, center, v.bp_q, dt)
	if v.hp_cut > 0.0:
		mixed = _highpass_1p(v, mixed, v.hp_cut, dt)
	if v.lp_cut1 > 0.0:
		var lp_cut: float = lerpf(v.lp_cut0, v.lp_cut1, progress)
		mixed = _lowpass_1p(v, mixed, lp_cut, dt)
	if v.drive > 0.0:
		mixed = _soft_clip(mixed, v.drive)
	return mixed


func _envelope(v: Voice, dt: float) -> float:
	if v.releasing:
		var release_ratio: float = exp(-6.0 * dt / maxf(v.release, 0.00001))
		v.release_level *= release_ratio
		return v.release_level

	if v.type == VoiceType.CHARGE:
		if v.t < v.attack:
			return v.t / maxf(v.attack, 0.00001)
		return 1.0

	if v.t < v.attack:
		return v.t / maxf(v.attack, 0.00001)

	if v.decay <= 0.00001:
		return 1.0

	var decay_t: float = (v.t - v.attack) / v.decay
	var decay_env: float = exp(-6.0 * decay_t)
	return maxf(v.sustain, decay_env)


func _lowpass_1p(v: Voice, x: float, cutoff: float, dt: float) -> float:
	var alpha: float = _onepole_alpha(cutoff, dt)
	v.lp_z = lerpf(v.lp_z, x, alpha)
	return v.lp_z


func _highpass_1p(v: Voice, x: float, cutoff: float, dt: float) -> float:
	var alpha: float = _onepole_alpha(cutoff, dt)
	v.hp_z = lerpf(v.hp_z, x, alpha)
	return x - v.hp_z


func _bandpass_approx(v: Voice, x: float, center: float, q: float, dt: float) -> float:
	var lp_alpha: float = _onepole_alpha(center, dt)
	v.bp_lp_z = lerpf(v.bp_lp_z, x, lp_alpha)
	var hp_cut: float = maxf(center / maxf(q, 0.01), 40.0)
	var hp_alpha: float = _onepole_alpha(hp_cut, dt)
	v.bp_hp_z = lerpf(v.bp_hp_z, v.bp_lp_z, hp_alpha)
	return v.bp_lp_z - v.bp_hp_z


func _onepole_alpha(cutoff: float, dt: float) -> float:
	return 1.0 - exp(-TAU * maxf(cutoff, 1.0) * dt)


func _soft_clip(x: float, amount: float) -> float:
	var k: float = 1.0 + amount * 8.0
	return tanh(x * k) / tanh(k)


func _jitter(base: float, pct: float) -> float:
	return base * (1.0 + _rng.randf_range(-pct, pct))
