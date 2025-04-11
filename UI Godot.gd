extends Control

# Define a signal to pass the processed side lengths to the backend.
signal sides_input(side_lengths)

# Node references.
@onready var side_input: TextEdit = $SideInputTextEdit
@onready var submit_button: Button = $SubmitButton
@onready var output_label: Label = $OutputLabel

func _ready():
	# Connect the button's pressed signal to our handler.
	submit_button.pressed.connect(_on_submit_pressed)

func _on_submit_pressed():
	# Retrieve raw text input (batch input of side lengths).
	var raw_text: String = side_input.text

	# Process the raw input: convert the text into an array of side lengths.
	var side_lengths: Array = _parse_side_lengths(raw_text)
	
	# Display a message indicating the input was received.
	output_label.text = "Input received: " + str(side_lengths)
	
	# Emit the signal with the side lengths.
	emit_signal("sides_input", side_lengths)
	
	# (Optionally, print the input to console for debugging.)
	print("Frontend collected side lengths: ", side_lengths)

# Helper function to parse a string of side lengths.
func _parse_side_lengths(input_text: String) -> Array:
	var side_values = []
	# First, split the input by newline (to handle one value per line).
	var lines: Array = input_text.split("\n", true)
	for line in lines:
		line = line.strip_edges()
		if line != "":
			# Further split by commas if present.
			if line.find(",") != -1:
				var tokens: Array = line.split(",", true)
				for token in tokens:
					token = token.strip_edges()
					if token != "":
						side_values.append(float(token))
			else:
				side_values.append(float(line))
	return side_values
