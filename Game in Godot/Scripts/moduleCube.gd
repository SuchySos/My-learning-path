extends Node3D


@onready var level = $"../"


func _process(delta):
	if position.z < -19:
		queue_free()
