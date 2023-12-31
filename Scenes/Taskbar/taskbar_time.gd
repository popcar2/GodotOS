extends Control

func _ready():
	update_time()

func update_time():
	var date_dict: Dictionary = Time.get_datetime_dict_from_system()
	var suffix: String
	if date_dict.hour >= 12:
		date_dict.hour -= 12
		suffix = "PM"
	else:
		suffix = "AM"
	
	$TimeText.text = "[center]%02d:%02d %s" % [date_dict.hour, date_dict.minute, suffix]
	$DateText.text = "[center]%02d/%02d/%d" % [date_dict.day, date_dict.month, date_dict.year]

func _on_timer_timeout():
	update_time()
