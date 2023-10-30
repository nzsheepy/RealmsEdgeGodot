extends Label

@onready var timerLabel = $LabelTimer
var current_wave = 1
var initial_wave_time = 10 * 60  # 10 minutes in seconds
var time_decrease_factor = 0.75  # Decrease time by 25% for each wave

# Called when the node enters the scene tree for the first time.
func _ready():
	start_new_wave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var total_seconds = int($Timer.time_left)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	text = "Next Wave in:\n%02d:%02d" % [minutes, seconds]

func _on_timer_timeout():
	print("Wave %d completed!" % current_wave)
	current_wave += 1
	start_new_wave()

func start_new_wave():
	var new_wave_time = initial_wave_time * pow(time_decrease_factor, current_wave - 1)
	$Timer.wait_time = new_wave_time
	$Timer.start()
