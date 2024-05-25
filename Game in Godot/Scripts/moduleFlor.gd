extends Node3D

@onready var level = $"../"

func _process(_delta):
	if position.z < -19:
		#level.spawnModule(position.z/level.offset+(level.lenght+8), position.x/level.offset, level.offset)
		var num = level.rng.randi_range(0,3)
		if num == 1:
			level.path_bufor[position.x/2] = 1
		else:
			level.path_bufor[position.x/2] = 0
		queue_free()
