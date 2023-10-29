extends MeshInstance3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation_degrees.x += 30 * delta
	rotation_degrees.z += 30 * delta
