extends Node2D

const PIXELS_PER_INCH = 100.0
var selected_model: CharacterBody2D = null
var distance_label: Label = null
var preview_circle: Sprite2D = null
var collider_radius: float = 0.0

func _ready():
	# Create the label
	var label = Label.new()
	label.name = "DistanceLabel"
	label.position = Vector2(20, 20)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	add_child(label)
	distance_label = label
	
	# Create preview circle using your imported texture
	var circle = Sprite2D.new()
	circle.name = "PreviewCircle"
	circle.texture = load("res://Preview_Circle.png")  # Load your PNG
	circle.centered = true
	circle.visible = false
	add_child(circle) 
	preview_circle = circle

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Try to select a model
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = get_global_mouse_position()
			query.collide_with_areas = true
			query.collide_with_bodies = true
			query.collision_mask = 1
			
			var result = space_state.intersect_point(query)
			for collision in result:
				if collision.collider is CharacterBody2D:
					selected_model = collision.collider
					
					# Get the collider radius and scale the preview
					var shape = selected_model.get_node("CollisionShape2D").shape
					if shape is CircleShape2D:
						collider_radius = shape.radius
						# Calculate scale factor based on texture size
						# To make the preview circle half as big, adjust the scale factor calculation
						var texture_size = preview_circle.texture.get_size().x / 2.0  # Get half the texture size
						var scale_factor = (collider_radius / texture_size) * 0.5  # Scale down by half
						preview_circle.scale = Vector2(scale_factor, scale_factor)
					
					preview_circle.visible = true
					break
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and selected_model:
			# Check for collisions before moving
			var target_position = get_global_mouse_position()
			var motion = target_position - selected_model.global_position
			
			# Update preview circle position
			preview_circle.global_position = target_position
			
			# Use test_move to check for collisions
			var collision = selected_model.move_and_collide(motion, true)
			
			if collision:
				# Collision detected - move up to collision point
				var safe_position = selected_model.global_position + motion.normalized() * (motion.length() - collision.get_remainder().length())
				selected_model.global_position = safe_position
				
				# Show collision feedback
				distance_label.text = "Stopped by collision"
				await get_tree().create_timer(1.0).timeout
				if distance_label:
					distance_label.text = ""
			else:
				# No collision - move all the way
				selected_model.global_position = target_position
			
			# Hide preview after moving
			preview_circle.visible = false
			selected_model = null
			if distance_label:
				distance_label.text = ""

func _process(delta):
	if selected_model and distance_label:
		var model_position = selected_model.global_position
		var mouse_position = get_global_mouse_position()
		var distance = model_position.distance_to(mouse_position)
		var inches = distance / PIXELS_PER_INCH
		update_measurement_display(inches)
		
		# Update preview circle position to follow mouse
		if preview_circle.visible:
			preview_circle.global_position = mouse_position

func update_measurement_display(inches):
	if distance_label:
		distance_label.text = "Distance: %.2f inches" % inches
