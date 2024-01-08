extends Control

## The time and date in the taskbar.
## Updates once every 10 seconds since string replacements can be a waste of resources.

func _ready() -> void:
	update_time()

func update_time() -> void:
	var date_dict: Dictionary = Time.get_datetime_dict_from_system()
	var suffix: String
	if date_dict.hour >= 12:
		date_dict.hour -= 12
		suffix = "PM"
	else:
		suffix = "AM"
		if date_dict.hour == 0:
			date_dict.hour = 12
	
	$TimeText.text = "[center]%02d:%02d %s" % [date_dict.hour, date_dict.minute, suffix]
	$DateText.text = "[center]%02d/%02d/%d" % [date_dict.day, date_dict.month, date_dict.year]

func _on_timer_timeout() -> void:
	update_time()
