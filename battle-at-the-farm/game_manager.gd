extends Node2D

const PIXELS_PER_INCH = 100.0
var selected_model: CharacterBody2D = null
var distance_label: Label = null
var preview_circle: Sprite2D = null
var collider_radius: float = 0.0
var friendly_group: String  = ""


func _ready():
	# Called when the node is added to the scene. Sets up the UI elements.

	# Create the label to display distance information.
	var label = Label.new()
	label.name = "DistanceLabel"  # Name the label for easy reference.
	label.position = Vector2(20, 20)  # Position the label on the screen.
	label.add_theme_font_size_override("font_size", 24)  # Set font size.
	label.add_theme_color_override("font_color", Color.WHITE)  # Set font color.
	label.add_theme_constant_override("outline_size", 2)  # Add text outline.
	label.add_theme_color_override("font_outline_color", Color.BLACK)  # Set outline color.
	add_child(label)  # Add the label to the scene tree.
	distance_label = label  # Store a reference to the label.

	# Create the preview circle for movement visualization.
	var circle = Sprite2D.new()
	circle.name = "PreviewCircle"  # Name the circle for easy reference.
	circle.texture = load("res://Preview_Circle.png")  # Load the texture for the circle.
	circle.centered = true  # Center the texture on the sprite.
	circle.visible = false  # Hide the circle initially.
	add_child(circle)  # Add the circle to the scene tree.
	preview_circle = circle  # Store a reference to the circle.

func _unhandled_input(event):
	# Handles unprocessed input events, such as mouse clicks.

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Left mouse button pressed: try to select a model.

			# Perform a physics query to detect objects under the mouse pointer.
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = get_global_mouse_position()  # Query at mouse position.
			query.collide_with_areas = true  # Include areas in the query.
			query.collide_with_bodies = true  # Include bodies in the query.
			query.collision_mask = 1  # Set the collision mask.

			var result = space_state.intersect_point(query)  # Perform the query.
			for collision in result:
				if collision.collider is CharacterBody2D:
					# If a CharacterBody2D is found, select it.
					selected_model = collision.collider

					# Get the collider radius and scale the preview circle accordingly.
					var shape = selected_model.get_node("CollisionShape2D").shape
					if shape is CircleShape2D:
						collider_radius = shape.radius  # Get the radius of the collider.

						# Calculate the scale factor for the preview circle.
						var texture_size = preview_circle.texture.get_size().x / 2.0  # Half the texture size.
						var scale_factor = (collider_radius / texture_size) * 0.5  # Scale down by half.
						preview_circle.scale = Vector2(scale_factor, scale_factor)  # Apply the scale.

					preview_circle.visible = true  # Show the preview circle.
					break

		elif event.button_index == MOUSE_BUTTON_RIGHT and selected_model:
			# Right mouse button pressed: move the selected model.
			var target_position = get_global_mouse_position()
			var motion = target_position - selected_model.global_position
			if selected_model.has_method("get_movement_range"):
				var max_distance = selected_model.get_movement_range()
				if motion.length() > max_distance:
					motion = motion.normalized() * max_distance

			# Determine friendly group(s)
			if selected_model.is_in_group("orks"):
				friendly_group = "orks"
			elif selected_model.is_in_group("marines"):
				friendly_group = "marines"

			var all_units = get_tree().get_nodes_in_group("units")
			var friendlies = []
			for unit in all_units:
				if unit != selected_model and friendly_group != "" and unit.is_in_group(friendly_group):
					unit.set_collision_layer(0)
					unit.set_collision_mask(0)
					friendlies.append(unit)

			# Now do movement/collision logic only once, outside the loop
			var can_move = not selected_model.test_move(selected_model.transform, motion)

			# Restore collision layers/masks for friendlies
			for friendly_unit in friendlies:
				friendly_unit.set_collision_layer(1)
				friendly_unit.set_collision_mask(1)

			var final_position = selected_model.global_position + motion
			var overlap = false
			if can_move:
				for other_unit in all_units:
					if other_unit != selected_model:
						var their_shape = other_unit.get_node("CollisionShape2D").shape
						var my_shape = selected_model.get_node("CollisionShape2D").shape
						var their_pos = other_unit.global_position
						var my_pos = final_position
						if my_shape is CircleShape2D and their_shape is CircleShape2D:
							var dist = my_pos.distance_to(their_pos)
							if dist < (my_shape.radius + their_shape.radius):
								overlap = true
								break
			if overlap:
				distance_label.text = "Cannot end move overlapping another unit"
				await get_tree().create_timer(1.0).timeout
				if distance_label:
					distance_label.text = ""
			else:
				selected_model.global_position = final_position
				distance_label.text = "Stopped by collision"
				await get_tree().create_timer(1.0).timeout
				if distance_label:
					distance_label.text = ""

			preview_circle.visible = false
			selected_model = null
			if distance_label:
				distance_label.text = ""  # Clear the label.

func _process(_delta):
	# Called every frame. Updates the UI and preview circle.

	if selected_model and distance_label:
		# Update the distance label with the distance to the mouse pointer.
		var model_position = selected_model.global_position
		var mouse_position = get_global_mouse_position()
		var distance = model_position.distance_to(mouse_position)  # Calculate distance.
		var inches = distance / PIXELS_PER_INCH  # Convert distance to inches.
		update_measurement_display(inches)  # Update the label.

		# Update the preview circle position to follow the mouse.
		if preview_circle.visible:
			var motion = mouse_position - selected_model.global_position
			if selected_model.has_method("get_movement_range"):
				# Restrict motion to the maximum movement range.
				var max_distance = selected_model.get_movement_range()
				if motion.length() > max_distance:
					motion = motion.normalized() * max_distance
			preview_circle.global_position = selected_model.global_position + motion  # Update position.

func update_measurement_display(inches):
	# Updates the distance label with the given distance in inches.
	if distance_label:
		distance_label.text = "Distance: %.2f inches" % inches  # Format and set the text.
