extends Control

# Signal to send side lengths to backend
signal sides_input(side_lengths)

# Main UI nodes
@onready var submit_button: Button = $SubmitButton
@onready var output_label: Label = $OutputLabel
@onready var add_furn_button: Button = $AddFurnitureButton

# Popup UI nodes
@onready var input_popup: Window = $InputPopup
@onready var side_input: TextEdit = $InputPopup/VBoxContainer/SideInputTextEdit
@onready var ok_button: Button = $InputPopup/VBoxContainer/OkButton

# Add Furniture Popup nodes
@onready var furniture_popup: Window = $FurniturePopup
@onready var name_input:LineEdit = $FurniturePopup/VBoxContainer/Name/LineEdit
@onready var width_input: LineEdit = $FurniturePopup/VBoxContainer/Width/LineEdit
@onready var depth_input: LineEdit = $FurniturePopup/VBoxContainer/Depth/LineEdit
@onready var height_input: LineEdit = $FurniturePopup/VBoxContainer/Height/LineEdit
@onready var posx_input: LineEdit = $FurniturePopup/VBoxContainer/PosX/LineEdit
@onready var posy_input: LineEdit = $FurniturePopup/VBoxContainer/PosY/LineEdit
@onready var posz_input: LineEdit = $FurniturePopup/VBoxContainer/PosZ/LineEdit
@onready var furn_ok_button: Button = $FurniturePopup/VBoxContainer/FurnOkButton
#@onready var furn_cancel_button: Button = $FurniturePopup/VBoxContainer/FurnCancelButton

var fdb: FurnitureDB

func _ready():
	fdb = FurnitureDB.new()
	add_child(fdb)
	
	# Room inputs
	submit_button.pressed.connect(_on_submit_button_pressed)
	ok_button.pressed.connect(_on_ok_button_pressed)
	input_popup.close_requested.connect(_on_input_popup_close_requested)

	# Furniture Inputs
	add_furn_button.pressed.connect(_on_add_furn_button_pressed)
	furn_ok_button.pressed.connect(_on_furn_ok_pressed)
	furniture_popup.close_requested.connect(_on_furn_popup_close_requested)
	
	# Hide popups
	input_popup.hide()
	furniture_popup.hide()

func _on_submit_button_pressed():
	# Clear previous input and show popup
	side_input.text = ""
	input_popup.popup_centered()

func _on_ok_button_pressed():
	var raw_text: String = side_input.text
	raw_text = raw_text.replace("\r", "")  # Normalize for Windows line endings

	var side_lengths: Array = _parse_side_lengths(raw_text)

	output_label.text = "Input received: " + str(side_lengths)
	emit_signal("sides_input", side_lengths)

	input_popup.hide()  # Hide popup after confirming
	if side_lengths.size() >= 2:
		var length = side_lengths[0]
		var width  = side_lengths[1]
		# use your fixed room_height or pull it from your extruder:
		var height = 5.0
		fdb.add_furniture(
			"Room",      # a name
			length,      # width
			width,       # depth
			height,      # height
			"room",      # type
			"res://House.tscn"  # scene or identifier
		)

func _on_input_popup_close_requested():
	input_popup.hide()  # Handle clicking the "X" in the popup title bar

func _parse_side_lengths(input_text: String) -> Array:
	var side_values = []
	var lines = input_text.split("\n")

	for line in lines:
		line = line.strip_edges()
		if line != "":
			if line.find(",") != -1:
				for token in line.split(","):
					token = token.strip_edges()
					if token.is_valid_float():
						side_values.append(float(token))
			elif line.is_valid_float():
				side_values.append(float(line))

	return side_values

func _on_add_furn_button_pressed():
	# clear fields
	name_input.text = ""
	width_input.text = ""
	depth_input.text = ""
	height_input.text = ""
	posx_input.text = ""
	posy_input.text = ""
	posz_input.text = ""
	furniture_popup.popup_centered()

func _on_furn_ok_pressed():
	var name = name_input.text.strip_edges()
	var w = float(width_input.text)
	var d = float(depth_input.text)
	var h = float(height_input.text)
	var x = float(posx_input.text)
	var y = float(posy_input.text)
	var z = float(posz_input.text)

	var data = {
		"name": name, "width": w, "depth": d, "height": h,
		"pos": Vector3(x, y, z)
		}
	# persist
	fdb.add_furniture(name, w, d, h, "box", "res://House.tscn")  

	emit_signal("add_furniture", data)
	furniture_popup.hide()

func _on_furn_popup_close_requested():
	furniture_popup.hide()
