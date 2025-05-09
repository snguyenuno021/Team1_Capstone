extends Control

# Signal to send side lengths to backend
signal sides_input(side_lengths)

# Main UI nodes
@onready var submit_button: Button = $SubmitButton
@onready var output_label: Label = $OutputLabel
@onready var add_furniture_button: Button = $AddFurnitureButton

# Popup UI nodes for room
@onready var input_popup: Window = $InputPopup
@onready var side_input: TextEdit = $InputPopup/VBoxContainer/SideInputTextEdit
@onready var ok_button: Button = $InputPopup/VBoxContainer/OkButton

# Popup UI nodes for furniture
@onready var furniture_popup: Window = $FurniturePopup
@onready var furniture_input: TextEdit = $FurniturePopup/VBoxContainer/FurnitureInputTextEdit
@onready var add_furniture_ok_button: Button = $FurniturePopup/VBoxContainer/AddFurnitureOkButton

var fdb: FurnitureDB
var furniture_offset := Vector3(0, 0, 0)  # Position tracker for added furniture

func _ready():
	fdb = FurnitureDB.new()
	add_child(fdb)
	# Connect buttons
	submit_button.pressed.connect(_on_submit_button_pressed)
	ok_button.pressed.connect(_on_ok_button_pressed)
	input_popup.close_requested.connect(_on_input_popup_close_requested)

	add_furniture_button.pressed.connect(_on_add_furniture_button_pressed)
	add_furniture_ok_button.pressed.connect(_on_add_furniture_ok_button_pressed)
	furniture_popup.close_requested.connect(_on_furniture_popup_close_requested)

	# Ensure popups start hidden
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

func _on_add_furniture_button_pressed():
	furniture_input.text = ""
	furniture_popup.popup_centered()

func _on_add_furniture_ok_button_pressed():
	var raw_text = furniture_input.text.strip_edges()
	var dims = []
	for token in raw_text.split(","):
		token = token.strip_edges()
		if token.is_valid_float():
			dims.append(token.to_float())

	if dims.size() == 3:
		var width = dims[0]
		var depth = dims[1]
		var height = dims[2]

		# Log entry to DB
		fdb.add_furniture(
			"CustomFurniture", width, depth, height, "custom", "res://FurnitureBlock.tscn"
		)

		_emit_furniture_block(width, depth, height)
	else:
		output_label.text = "Please enter 3 comma-separated values (width, depth, height)"

	furniture_popup.hide()

func _on_furniture_popup_close_requested():
	furniture_popup.hide()

func _emit_furniture_block(width: float, depth: float, height: float):
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, height, depth)
	mesh_instance.mesh = mesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.0, 1.0, 0.0)
	mesh_instance.material_override = mat

	# Position and offset logic
	mesh_instance.position = furniture_offset + Vector3(0, height / 2.0, 0)
	furniture_offset.x += width + 1.0  # Shift next block over by width + padding

	get_tree().get_root().add_child(mesh_instance)

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
