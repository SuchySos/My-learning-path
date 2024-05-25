extends Node3D

@onready var player: = $"../../player"
@onready var control: = $"../../../Control"

var bufor = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Flach.rotation.y += delta
	bufor += delta
	$Flach.position.y = 0.5 + sin(bufor)/2
	if self.position == player.position:
		control.regen(0,3)
		queue_free()
