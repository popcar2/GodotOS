extends TextEdit

func _input(event: InputEvent):
	if event.is_action_pressed("rename") and $"../../../Selected Highlight".visible:
		show_rename()
	
	if !get_parent().visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		trigger_rename()
	
	if event.is_action_pressed("ui_cancel"):
		cancel_rename()
	
	if event is InputEventMouseButton and event.is_pressed():
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0), size).has_point(evLocal.position):
			cancel_rename()

func show_rename():
	get_parent().visible = true
	grab_focus()
	text = %"Folder Title".text.trim_prefix("[center]").split(".")[0]
	select_all()

func trigger_rename():
	get_parent().visible = false
	#TODO stop file from adding periods
	var folder: FakeFolder = $"../../.."
	if folder.file_type != folder.file_type_enum.FOLDER:
		var old_folder_name: String = folder.folder_name
		var new_folder_name: String = "%s.%s" % [text, folder.folder_name.split('.')[-1]]
		if FileAccess.file_exists("user://files/%s/%s" % [folder.folder_path, new_folder_name]):
			cancel_rename()
			NotificationManager.spawn_notification("That file already exists!")
			return
		folder.folder_name = new_folder_name
		DirAccess.rename_absolute("user://files/%s/%s" % [folder.folder_path, old_folder_name], "user://files/%s/%s" % [folder.folder_path, folder.folder_name])
		%"Folder Title".text = "[center]%s" % folder.folder_name
		
		if folder.get_parent() is DesktopFileManager:
			folder.get_parent().sort_file(folder)
			folder.get_parent().update_positions()
		else:
			# Reloads open windows
			for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
				if file_manager.file_path == folder.folder_path:
					file_manager.sort_file(folder)
					file_manager.update_positions()
		for text_editor in get_tree().get_nodes_in_group("text_editor_window"):
			if text_editor.file_path == "%s/%s" % [folder.folder_path, old_folder_name]:
				text_editor.file_path = "%s/%s" % [folder.folder_path, folder.folder_name]
			elif text_editor.file_path == old_folder_name: # In desktop
				text_editor.file_path = folder.folder_name 
	
	elif folder.file_type == folder.file_type_enum.FOLDER:
		var old_folder_name: String = folder.folder_name
		var old_folder_path: String = folder.folder_path
		
		if old_folder_path.contains("/"):
			var new_folder_path: String = "%s%s" % [folder.folder_path.trim_suffix(old_folder_name), text]
			if DirAccess.dir_exists_absolute("user://files/%s" % new_folder_path):
				cancel_rename()
				NotificationManager.spawn_notification("That folder already exists!")
				return
			folder.folder_path = new_folder_path
		else:
			if DirAccess.dir_exists_absolute("user://files/%s" % text):
				cancel_rename()
				NotificationManager.spawn_notification("That folder already exists!")
				return
			folder.folder_path = text
		folder.folder_name = text
		%"Folder Title".text = "[center]%s" % folder.folder_name
		DirAccess.rename_absolute("user://files/%s" % old_folder_path, "user://files/%s" % folder.folder_path)
		
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path.begins_with(old_folder_path):
				file_manager.file_path = file_manager.file_path.replace(old_folder_path, folder.folder_path)
				file_manager.reload_window("")
			elif file_manager.file_path == folder.folder_path.trim_suffix("/%s" % folder.folder_name):
				file_manager.sort_file(folder)
				file_manager.update_positions()
	
	text = ""

func cancel_rename():
	get_parent().visible = false
	text = ""
