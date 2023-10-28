extends TextEdit

func _input(event: InputEvent):
	if event.is_action_pressed("rename") and $"../../../Selected Highlight".visible:
		get_parent().visible = true
		grab_focus()
	
	if !get_parent().visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		get_parent().visible = false
		#TODO stop file from adding periods
		var folder: FakeFolder = $"../../.."
		if folder.file_type != folder.file_type_enum.FOLDER:
			var old_folder_name: String = folder.folder_name
			folder.folder_name = "%s.%s" % [text, folder.folder_name.split('.')[-1]]
			print("user://%s/%s" % [folder.folder_path, old_folder_name])
			DirAccess.rename_absolute("user://files/%s/%s" % [folder.folder_path, old_folder_name], "user://files/%s/%s" % [folder.folder_path, folder.folder_name])
			%"Folder Title".text = "[center]%s" % folder.folder_name
			#TODO reload all windows?
		
		text = ""
