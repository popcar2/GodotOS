class_name VirtualPathManager
## Utility class to work with paths within the GodotOS.
##
## All the logic works around one important idea, [u]"virtual path"[/u].
## The user can [b]not[/b] interact with the real paths, for security and implementation reasons,
## so all the folders and files accessed by it have a virtual path.[br]
##
## Only the backend can work with the real paths on the user machine, then when a
## folder or file is created the user just sees [member _virtual_path] by using
## [method get_path] for example, but in reality the path consist of [member _ROOT_PATH] + [member _virtual_path].
##
## For example:
##[codeblock]
### what the user sees:
##"" -> mkdir -> "folder"
##"folder" -> mkdir -> "folder/sub_folder"
##
### what actualy happens:
##"user://files" -> mkdir -> "user://files/folder"
##"user://files/folder" -> mkdir -> "user://files/folder/sub_folder"
##[/codeblock]

## The real root path used together with [member _virtual_path] to access folders and files in the user machine.
const _ROOT_PATH: String = "user://files"

## The path within the GodotOS that the user can see and interact
## using [method get_path], [method set_path], [method get_base_dir], etc...
var _virtual_path: String = ""

## Emited when [member _virtual_path] is changed.
signal on_virtual_path_changes(new_virtual_path: String)


## Returns [member _virtual_path].
func get_path() -> String:
	return _virtual_path


## Returns [member _ROOT_PATH] + [member _virtual_path] after sanitization.
func _get_real_path(virt_path: String = "=") -> String:
	return _ROOT_PATH.path_join(virt_path).simplify_path()


## Asserts that [param new_virt_path] is a valid folder, then sets [member _virtual_path].[br]
## NOTE: [member _virtual_path] will never be a file, just a folder.
func set_path(new_virt_path: String) -> void:
	_assert_folder(new_virt_path)
	
	_virtual_path = new_virt_path.simplify_path()
	on_virtual_path_changes.emit(new_virt_path)


## Returns [member _virtual_path] up one folder.[br]
## For example:
##[codeblock]
##"folder/sub_folder".get_base_dir() -> "folder"
##[/codeblock]
func get_base_dir() -> String:
	return _virtual_path.get_base_dir()


## Returns the current folder.[br]
## For example:
##[codeblock]
##"folder/sub_folder".get_current_folder() -> "sub_folder"
##[/codeblock]
func get_current_folder() -> String:
	return _virtual_path.simplify_path().get_file()


## Checks if given [param virtual_path] do not go outside [code]"user://files"[/code].
func is_legal_path(virt_path: String = "=") -> bool:
	var real_path: String = _ROOT_PATH
	
	if virt_path == '=':
		real_path = real_path.path_join(_virtual_path)
	else:
		real_path = real_path.path_join(virt_path)
	
	real_path = real_path.simplify_path()
	
	if not real_path.begins_with(_ROOT_PATH):
		return false
	
	return true


## Returns true if a file exists in [member _ROOT_PATH] + [member _virtual_path].
func path_is_valid_file(virt_path: String) -> bool:
	if not is_legal_path(virt_path):
		return false
	
	return FileAccess.file_exists(_get_real_path(virt_path))


## Returns true if a folder exists in [member _ROOT_PATH] + [member _virtual_path].
func path_is_valid_folder(virt_path: String) -> bool:
	if not is_legal_path(virt_path):
		return false
	
	var dir := DirAccess.open(_get_real_path(virt_path))
	return dir != null


## Opens a file in path [member _ROOT_PATH] + [member _virtual_path], using [param flags] and return it.[br]
## NOTE: This function don't check and will crash if the file do not exist,
## for this use [method path_is_valid_file].
func open_file(virt_path: String, flags: FileAccess.ModeFlags) -> FileAccess:
	_assert_file(virt_path)
	
	return FileAccess.open(_get_real_path(virt_path), flags)


## Return a list with all files at path [param virt_path].[br]
## If [param virt_path] == [code]""[/code] returns the files in [member _virtual_path] instead.[br]
## NOTE: This function don't check and will crash if the file do not exist,
## for this use [method path_is_valid_file].
func list_files(virt_path: String = "") -> PackedStringArray:
	if virt_path == "":
		return DirAccess.open(_get_real_path(_virtual_path)).get_files()
	
	_assert_folder(virt_path)
	return DirAccess.open(_get_real_path(virt_path)).get_files()


## Return a list with all folders at path [param virt_path].[br]
## If [param virt_path] == [code]""[/code] returns the folders in [member _virtual_path] instead.[br]
## NOTE: This function don't check and will crash if the folder do not exist,
## for this use [method path_is_valid_folder].
func list_directories(virt_path: String = ".") -> PackedStringArray:
	if virt_path == '.':
		return DirAccess.open(_get_real_path(_virtual_path)).get_directories()
	
	_assert_folder(virt_path)
	return DirAccess.open(_get_real_path(virt_path)).get_directories()


func _assert_file(path: String) -> void:
	assert(path_is_valid_file(path), path + " is not a file or do not exist")


func _assert_folder(path: String) -> void:
	assert(path_is_valid_folder(path), path + " is not a folder or do not exist")
