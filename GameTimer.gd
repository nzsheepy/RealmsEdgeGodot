extends Label

@onready var timerLabel = $LabelTimer
@onready var espawn = $"../../../../EnemySpawner"
@onready var necromancers = $"../../../../Necromancers"
@onready var textScroll = $"../../../../HUD/HUD/Text_for_scroll/text_Scroll/PanelPopText/HBoxContainer/LabelPopText"
@onready var textPanel = $"../../../../HUD/HUD/Text_for_scroll/text_Scroll/PanelPopText"
@onready var waveTexture = get_node("../../../../HUD/HUD/Text_for_scroll/TextureWaveIncoming")
@export var minimum_wave_time = 10.0  # Minimum time in seconds for a wave

var current_wave = 1
@export var initial_wave_time = 1 * 10  # 10 minutes in seconds
@export var waveShortner : bool = true  # Toggle for shortening wave times
var time_decrease_factor = 0.75  # Decrease time by 25% for each wave
var elapsed_time = 0.0  # To accumulate the time elapsed
var text_reveal_time = 3.0  # Time at which the text starts to reveal
var text_reveal_duration = 2.0  # Duration over which the text is revealed
var text_hold_time = 10.0  # Time to hold the text visible
var text_hide_duration = 2.0  # Duration over which the text is hidden
var text_state = "idle"  # "idle", "revealing", "holding", "hiding"
var welcome_message_shown = false  # To track whether the welcome message has been shown

var wave_texture_state = "hidden"  # "hidden", "fading_in", "visible", "fading_out"
var wave_texture_fade_in_time = 1.0  # Time to fade in the waveTexture
var wave_texture_visible_time = 3.0  # Time to keep the waveTexture fully visible
var wave_texture_fade_out_time = 1.0  # Time to fade out the waveTexture
var wave_texture_elapsed_time = 0.0  # To accumulate the time for waveTexture


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../../../../HUD/HUD/Text_for_scroll/text_Scroll").hide()

	start_new_wave()
	textPanel.modulate.a = 0.0  # Hide the text panel
	waveTexture.hide()

func _process(delta):
	elapsed_time += delta  # Accumulate the time elapsed
	var total_seconds = int($WaveTimer.time_left)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	text = "  Next Wave in:\n  %02d:%02d" % [minutes, seconds]

	if !welcome_message_shown:
		match text_state:
			"idle":
				if elapsed_time >= text_reveal_time:
					get_node("../../../../HUD/HUD/Text_for_scroll/text_Scroll").show()
					textScroll.text = "Welcome my lord, our people need houses to live in.\nUse the build button in the bottom right corner to build" 
					text_state = "revealing"
					elapsed_time = 0  # Reset elapsed time for text revealing
			"revealing":
				var ratio = min(elapsed_time / text_reveal_duration, 1.0)
				textScroll.visible_ratio = ratio
				textPanel.modulate.a = ratio  # Fade in the text panel
				if ratio == 1.0:
					text_state = "holding"
					elapsed_time = 0  # Reset elapsed time for holding
			"holding":
				if elapsed_time >= text_hold_time:
					text_state = "hiding"
					elapsed_time = 0  # Reset elapsed time for hiding
			"hiding":
				var ratio = max(1.0 - elapsed_time / text_hide_duration, 0.0)
				textScroll.visible_ratio = ratio
				textPanel.modulate.a = ratio  # Fade out the text panel
				if ratio == 0.0:
					get_node("../../../../HUD/HUD/Text_for_scroll/text_Scroll").hide()
					text_state = "idle"
					welcome_message_shown = true  # Set to true so it doesn't show again
					elapsed_time = 0  # Reset elapsed time

	match wave_texture_state:
		"hidden":
			# Nothing to do when hidden
			pass
		"fading_in":
			wave_texture_elapsed_time += delta
			var fade_in_ratio = min(wave_texture_elapsed_time / wave_texture_fade_in_time, 1.0)
			waveTexture.modulate.a = fade_in_ratio
			if fade_in_ratio == 1.0:
				wave_texture_state = "visible"
				wave_texture_elapsed_time = 0  # Reset elapsed time for visibility
		"visible":
			wave_texture_elapsed_time += delta
			if wave_texture_elapsed_time >= wave_texture_visible_time:
				wave_texture_state = "fading_out"
				wave_texture_elapsed_time = 0  # Reset elapsed time for fading out
		"fading_out":
			wave_texture_elapsed_time += delta
			var fade_out_ratio = max(1.0 - wave_texture_elapsed_time / wave_texture_fade_out_time, 0.0)
			waveTexture.modulate.a = fade_out_ratio
			if fade_out_ratio == 0.0:
				wave_texture_state = "hidden"
				waveTexture.hide()  # Hide the texture when fully faded out




func start_new_wave():
	var new_wave_time = initial_wave_time
	if waveShortner:
		new_wave_time *= pow(time_decrease_factor, current_wave - 1)
		# Ensure new_wave_time does not go below the minimum wave time
		new_wave_time = max(new_wave_time, minimum_wave_time)
	$WaveTimer.wait_time = new_wave_time
	$WaveTimer.start()

func _on_wave_timer_timeout():
	print("Wave %d completed!" % current_wave)
	current_wave += 1
	start_new_wave()
	espawn.startwave()
	espawn.increase_wave_size()  # Increase the wave size for the next wave exponentially

	for child in necromancers.get_children():
		child.startwave()
		child.increase_wave_size()  # Increase the wave size for necromancer waves as well


# Start fading in the waveTexture when the wave timer runs out
	wave_texture_state = "fading_in"
	wave_texture_elapsed_time = 0  # Reset elapsed time for fading in
	waveTexture.show()  # Make sure the texture is visible before starting to fade in