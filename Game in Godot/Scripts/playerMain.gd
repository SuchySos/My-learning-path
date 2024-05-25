extends Node3D

@onready var back: = $Ray_Z2
@onready var forward: = $Ray_Z1
@onready var right: = $Ray_X2
@onready var left: = $Ray_X1
@onready var CtrlNode = $"../../Control"
@onready var animator = $AnimationPlayer
@onready var level: = $"../GridMap"

var currposition = [8,0,0]

signal moved

# Called when the node enters the scene tree for the first time.
func _ready():
	if CtrlNode:
		CtrlNode.connect('Buttonpress', PlayerMove)


func PlayerMove(xz):
	if xz == 0:
		get_node("MeshInstance3D").look_at(self.position + Vector3(2,1,0))
		if not collision_check(left):
			currposition[0] += 2
			animator.play("ROLLL")
	elif xz == 3:
		get_node("MeshInstance3D").look_at(self.position + Vector3(-2,1,0))
		if not collision_check(right):
			currposition[0] -= 2
			animator.play("ROLLR")
	elif xz == 2:
		get_node("MeshInstance3D").look_at(self.position + Vector3(0,1,2))
		if not collision_check(forward):
			animator.play("ROLLF")
	elif xz == 1:
		get_node("MeshInstance3D").look_at(self.position + Vector3(0,1,-2))
		if not collision_check(back):
			animator.play("ROLLB")
	self.position = Vector3(currposition[0], currposition[1], currposition[2])
	await get_tree().create_timer(0.1).timeout
	
	var children = level.get_children()

	for child in children:
		var x = child.get_node("StaticBody3D")
		if x:
			change_texture_on_object(x, 0)
		x = child.get_node("HitMarkerCorner")
		if x:
			x = x.get_parent()
			x.queue_free()
	emit_signal("moved")


func collision_check(direc):
	return direc.is_colliding()


func change_texture_on_object(node,path):
	var static_body = node # Zakładając, że obiekt jest dzieckiem bieżącego węzła
	var mesh_instance = static_body.get_node("Flor") # Zakładając, że obiekt ma MeshInstance, który renderuje geometrię
	if mesh_instance:
		var new_texture = preload("res://assects/64px_grass6.png")
		if path == 1:
			new_texture = preload("res://assects/64px_red_2.png") # Ścieżka do nowej tekstury
		var new_material = StandardMaterial3D.new()
		new_material.albedo_texture = new_texture
		mesh_instance.set_surface_override_material(0, new_material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
