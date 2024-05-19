extends Node
class_name SaveSystem

const USE_ENCRYPTION = false
const SAVE_EXTENSION = "json"
const SAVE_FOLDER = "user://"
const BASE_FILE_NAME = "savegame"

# Generate a secure random key for encryption. This should be stored securely if you need consistent access to the file across sessions.
static func generate_key() -> PackedByteArray:
	var key = PackedByteArray()
	for i in range(32): # 32 bytes for AES-256 encryption
		key.append(randi() % 256)
	return key

# Alternatively, define a static key (not recommended for production!)
static var static_key = PackedByteArray([0x42, 0x26, 0x3E, 0xA5, 0x41, 0x66, 0xAC, 0x4F, 0x9F, 0x9E, 0x53, 0xE7, 0xE8, 0xBB, 0x3E, 0x5F,
0xE6, 0xBC, 0xDF, 0x85, 0xDE, 0x33, 0x2D, 0x7C, 0x7F, 0x74, 0x1C, 0x72, 0x3E, 0x3F, 0x78, 0x62])

# Generates a unique save file name based on the current date and time
static func generate_save_file_name():
	var datetime = Time.get_datetime_dict_from_system()
	var date_str = "%d-%02d-%02dT%02d-%02d-%02d" % [datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute, datetime.second]
	return "%s%s_%s.%s" % [SAVE_FOLDER, BASE_FILE_NAME, date_str, SAVE_EXTENSION]

# Saves the specified data to a file
static func save_data(data, save_file_name=null):
	if save_file_name == null:
		save_file_name = generate_save_file_name()
	else:
		save_file_name = "%s%s" % [SAVE_FOLDER, save_file_name]
	
	var file
	if USE_ENCRYPTION:
		file = FileAccess.open_encrypted(save_file_name, FileAccess.WRITE, static_key)
	else:
		file = FileAccess.open(save_file_name, FileAccess.WRITE)
	if not file:
		printerr("Failed to open file for writing: ", save_file_name)
		return save_file_name

	var json_string = JSON.stringify(data)
	
	file.store_string(json_string)
	file.close()
	
	print(save_file_name)
	if not FileAccess.file_exists(save_file_name):
		printerr("File does not exist: ", save_file_name)
		
	return save_file_name

# Loads data from the specified save file
static func load_data(save_file_name):
	var file_path = "%s%s" % [SAVE_FOLDER, save_file_name]
	if not FileAccess.file_exists(file_path):
		printerr("File does not exist: ", file_path)
		return null
	var file
	if USE_ENCRYPTION:
		file = FileAccess.open_encrypted(file_path, FileAccess.READ, static_key)
	else:
		file = FileAccess.open(file_path, FileAccess.READ)
	if file.get_open_error() != OK:
		printerr("Failed to open file for reading: ", file_path)
		return null
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var result = json.parse(json_string)
	if result == OK:
		return json.data
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	return

# Retrieves information about all the save files in the save folder
static func get_save_files_info():
	var directory = DirAccess.open(SAVE_FOLDER)
	if DirAccess.get_open_error() != OK:
		printerr("Directory does not exist: ", SAVE_FOLDER)
		return []
	
	var files = directory.get_files()
	return files
