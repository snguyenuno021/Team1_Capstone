extends Control

# Signal to send side lengths to backend
signal sides_input(side_lengths)

# Main UI nodes
@onready var submit_button: Button = $SubmitButton
@onready var output_label: Label = $OutputLabel

# Popup UI nodes
@onready var input_popup: Window = $InputPopup
@onready var side_input: TextEdit = $InputPopup/VBoxContainer/SideInputTextEdit
@onready var ok_button: Button = $InputPopup/VBoxContainer/OkButton

func _ready():
	# Connect buttons
	submit_button.pressed.connect(_on_submit_button_pressed)
	ok_button.pressed.connect(_on_ok_button_pressed)
	input_popup.close_requested.connect(_on_input_popup_close_requested)

	# Ensure popup starts hidden
	input_popup.hide()

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
        FurnitureDB.add_furniture(
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
