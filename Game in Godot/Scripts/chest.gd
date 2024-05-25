extends Node3D

@onready var player: = $"../../player"
@onready var animator: = $"chest/AnimationPlayer"
@onready var CtrlNode: = $"../../../Control"


func _ready():
	if CtrlNode:
		CtrlNode.connect('Buttonpress', OpenChest)


func OpenChest(_xz):
	if not animator.is_playing():
		if player.position == self.position:
			animator.play("ArmatureAction")
			print("skrzynia")
	
