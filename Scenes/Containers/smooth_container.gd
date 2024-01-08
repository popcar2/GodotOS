extends Control
class_name SmoothContainer

## Smoothly tweens all children into place. Used in file managers.

@export_enum("Horizontal", "Vertical") var direction: String = "Horizontal"
## How often the update function runs, in seconds. Low values are performance intensive!
@export var poll_rate: float = 0.15
## The speed of the Tween animation, in seconds.
@export var animation_speed: float = 0.5

@export_group("Spacing")
@export var horizontal_spacing: int = 10
@export var vertical_spacing: int = 10

@export_group("Margins")
@export var left_margin: int
@export var up_margin: int
@export var right_margin: int
@export var down_margin: int

## Global Tween so it doesn't create one each time the function runs
var tween: Tween
## Bool used to check if there's a cooldown or not
var just_updated: bool
## Global Vector2 to calculate the next position of each container child
var next_position: Vector2

## How many folders make up a line (column or row)
var line_count: int

var start_min_size: Vector2

func _ready() -> void:
	# I don't know why but having a container parent forces this node's size to be (0, 0) in the first frame
	await get_tree().physics_frame
	start_min_size = custom_minimum_size
	update_positions(false)

func update_positions(update_again: bool = true) -> void:
	if just_updated:
		return
	
	if update_again:
		cooldown_update()
	
	next_position = Vector2(left_margin, up_margin)
	if tween: tween.kill()
	
	if direction == "Horizontal":
		update_horizontal_direction()
	elif direction == "Vertical":
		update_vertical_direction()

func update_horizontal_direction() -> void:
	var new_line_count: int = 0
	line_count = 0
	
	var tallest_child: int = 0
	
	for child: Node in get_children():
		if !(child is FakeFolder):
			continue
		
		if next_position.x + right_margin + child.size.x > size.x:
			next_position.x = left_margin
			next_position.y += tallest_child + vertical_spacing
			tallest_child = 0
			
			line_count = new_line_count
			new_line_count = 0
		
		if child.position != next_position:
			if tween == null or !tween.is_running():
				restore_tween()
			tween.tween_property(child, "position", next_position, animation_speed)
		
		if child.size.y > tallest_child:
			tallest_child = child.size.y
		
		next_position.x += child.size.x + horizontal_spacing
		new_line_count += 1
	
	if line_count == 0:
		line_count = new_line_count
	
	if get_parent() is ScrollContainer:
		if next_position.y + tallest_child > get_parent().size.y:
			custom_minimum_size.y = next_position.y + tallest_child + down_margin
		else:
			custom_minimum_size.y = start_min_size.y
	

func update_vertical_direction() -> void:
	var new_line_count: int = 0
	line_count = 0
	
	var longest_child: int = 0
	for child: Node in get_children():
		if !(child is Control):
			continue
		
		if next_position.y + down_margin + child.size.y > size.y:
			next_position.y = up_margin
			next_position.x += longest_child + horizontal_spacing
			longest_child = 0
			
			line_count = new_line_count
			new_line_count = 0
		
		if child.position != next_position:
			if tween == null or !tween.is_running():
				restore_tween()
			tween.tween_property(child, "position", next_position, animation_speed)
		
		if child.size.x > longest_child:
			longest_child = child.size.x
		
		next_position.y += child.size.y + vertical_spacing
		new_line_count += 1
	
	if line_count == 0:
		line_count = new_line_count
	
	if get_parent() is ScrollContainer:
		if next_position.x + longest_child > get_parent().size.x:
			custom_minimum_size.x = next_position.x + longest_child + right_margin
		else:
			custom_minimum_size.x = start_min_size.x

## Creates a cooldown of x seconds rather than using the function every single frame.
## Plays the function again after poll rate ends to readjust positions.
func cooldown_update() -> void:
	just_updated = true
	await get_tree().create_timer(poll_rate).timeout
	just_updated = false
	update_positions(false)

func restore_tween() -> void:
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
