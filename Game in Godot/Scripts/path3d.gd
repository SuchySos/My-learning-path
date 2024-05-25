extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if %PathFollow3D:
		if %PathFollow3D.progress_ratio > 0.995:
			queue_free()
	
