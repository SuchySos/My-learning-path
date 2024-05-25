extends Node3D

@onready var back: = $Ray_Z2
@onready var forward: = $Ray_Z1
@onready var right: = $Ray_X2
@onready var left: = $Ray_X1
@onready var back2: = $Ray_Z4
@onready var forward2: = $Ray_Z3
@onready var right2: = $Ray_X4
@onready var left2: = $Ray_X3
@onready var level: = $"../"
@onready var player: = $"../../player"
@onready var animator: = $AnimationPlayer
@onready var control: = $"../../../Control"
signal hit
var rng = RandomNumberGenerator.new()
var num = 5
var dmg = 1
var drown = 3
var hitfromhitmark = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if player:
		player.connect('moved', EnemMove)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func EnemMove():
	var living = true
	if drown < 1 :
		queue_free()
	if position.z < -19:
		queue_free()
	if self.position - player.position == Vector3(0,0,0):
		queue_free()
		if hitfromhitmark:
			control.gethit(dmg)
		living = false
	hitfromhitmark = false
	if living:
		var currposition = [self.position.x,self.position.y,self.position.z]
		
		if num == 0:
			if not collision_check(left):
				currposition[0] += 2
				animator.play("ROLLL")
		elif num == 1:
			if not collision_check(right):
				currposition[0] -= 2
				animator.play("ROLLR")
		elif num == 2:
			if not collision_check(back):
				currposition[2] -= 2
				animator.play("ROLLB")
		elif num == 3:
			if not collision_check(forward):
				currposition[2] += 2
				animator.play("ROLLF")
		
		self.position = Vector3(currposition[0], currposition[1], currposition[2])
		num = rng.randi_range(0,3)
		
		if self.position - player.position == Vector3(0,0,0):
			queue_free()
			control.gethit(dmg)
			living = false
		if position.z > 58:
			queue_free()
			living = false
		
		if living:
			if num == 0:
				get_node("Rat (1)").look_at(self.position + Vector3(2,0.4,0))
				left2.force_raycast_update()
				if collision_check(left2):
					#var node = get_node(left2.get_collider().get_path())
					#change_texture_on_object(node, 1)
					level.spawnModuleX(self.position.z/2,1+self.position.x/2,level.offset,6)
					if 2+self.position.x == player.position.x and self.position.z == player.position.z:
						hitfromhitmark = true
			elif num == 1:
				get_node("Rat (1)").look_at(self.position + Vector3(-2,0.4,0))
				right2.force_raycast_update()
				if collision_check(right2):
					#var node = get_node(right2.get_collider().get_path())
					#change_texture_on_object(node, 1)
					level.spawnModuleX(self.position.z/2,-1+self.position.x/2,level.offset,6)
					if -2+self.position.x == player.position.x and self.position.z == player.position.z:
						hitfromhitmark = true
			elif num == 2:
				get_node("Rat (1)").look_at(self.position + Vector3(0,0.4,-2))
				back2.force_raycast_update()
				if collision_check(back2):
					#var node = get_node(back2.get_collider().get_path())
					#change_texture_on_object(node, 1)
					level.spawnModuleX(-1+self.position.z/2,self.position.x/2,level.offset,6)
					if self.position.x == player.position.x and -2+self.position.z == player.position.z:
						hitfromhitmark = true
			elif num == 3:
				get_node("Rat (1)").look_at(self.position + Vector3(0,0.4,2))
				forward2.force_raycast_update()
				if collision_check(forward2):
					#var node = get_node(forward2.get_collider().get_path())
					#change_texture_on_object(node, 1)
					level.spawnModuleX(1+self.position.z/2,self.position.x/2,level.offset,6)
					if self.position.x == player.position.x and 2+self.position.z == player.position.z:
						hitfromhitmark = true
	if collision_check(left) and collision_check(right) and collision_check(back) and collision_check(forward):
		drown = drown - 1


func change_texture_on_object(node,path):
	var static_body = node # Zakładając, że obiekt jest dzieckiem bieżącego węzła
	var mesh_instance = static_body.get_node("Flor") # Zakładając, że obiekt ma MeshInstance, który renderuje geometrię
	if mesh_instance:
		var new_texture = preload("res://assects/64px_red_1.png")
		if path == 1:
			new_texture = preload("res://assects/64px_red_2.png") # Ścieżka do nowej tekstury
		var new_material = StandardMaterial3D.new()
		new_material.albedo_texture = new_texture
		mesh_instance.set_surface_override_material(0, new_material)


func collision_check(direc):
	return direc.is_colliding()
