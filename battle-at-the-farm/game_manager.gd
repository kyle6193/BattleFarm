extends Node2D

# Define a conversion factor if necessary, e.g. pixels per inch
const PIXELS_PER_INCH = 100.0  # Adjust this value according to your game's scale

# Declare the selected model as a member variable
var selected_model

# Called when a model (like ork) is clicked.
func _on_model_clicked(model):
	# Store the initially selected model for reference while moving the mouse.
	selected_model = model

# Called each frame to update the live measurement if a model is selected.
func _process(delta):
	if selected_model:
		var model_position = selected_model.global_position
		var mouse_position = get_global_mouse_position()
		var distance = model_position.distance_to(mouse_position)
		var inches = distance / PIXELS_PER_INCH
		
		# Update your UI or draw the measurement on screen
		update_measurement_display(inches)

# Helper function to update on-screen measurement (example)
func update_measurement_display(inches):
	# This is a placeholder: implement your UI update (e.g., using a Label or drawing text).
	print("Distance: %.2f inches" % inches)
