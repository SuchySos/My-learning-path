extends GridMap

@export var modules: Array[PackedScene] = []

@onready var back: = $"../player/Ray_Z2"
@onready var forward: = $"../player/Ray_Z1"
@onready var right: = $"../player/Ray_X2"
@onready var left: = $"../player/Ray_X1"
@onready var CtrlNode = $"../../Control"

signal score

var lenght = 30
var rng = RandomNumberGenerator.new()
var offset = 2
var wight = 10
var pointsbuffor = 0
var points = 0
var path = 4
var path_his = []
var path_bufor = [0,0,0,0,0,0,0,0,0,0]
var chesttimer = 0


func _ready():
	for n in range(20):
		n = n - 18
		spawnModuleBand(n, offset)
		for i in wight:
			spawnModuleX(n, i, offset, 0)
	for n in lenght:
		if n > 1:
			for i in wight:
				var num = rng.randi_range(0,5)
				if num == 1:
					path_bufor[i] = 1
			var num = rng.randi_range(0,1)
			if num == 1:
				num = rng.randi_range(0,1)
				if num == 1:
					num = rng.randi_range(path,9)
					for i in range(path,num):
						path_bufor[i] = 0
				else:
					num = rng.randi_range(0,path)
					for i in range(path-num,path):
						path_bufor[i] = 0
			else:
				path_bufor[path] = 0
			path_his.append(path_bufor)
			path_bufor = [0,0,0,0,0,0,0,0,0,0]
	for n in lenght:
		if n > 1:
			spawnModuleBand(n,offset)
			for i in wight:
				spawnModuleX(n,i,offset,0)
				if path_his[n-2][i] == 1:
					spawnModuleX(n,i,offset,1)
				else:
					var num = rng.randi_range(0,60)
					if num < 2:
						spawnModuleX(n,i,offset,2)
	spawnModuleX(1,4,offset,4)
	spawnModuleX(1,5,offset,6)
	if CtrlNode:
		CtrlNode.connect('Buttonpress', PlayerMove)


func spawnModuleBand(z, offset):
	var instance = modules[3].instantiate()
	instance.position.z = z * offset
	instance.position.x = -1 * offset
	add_child(instance)
	instance = modules[3].instantiate()
	instance.position.z = z * offset
	instance.position.x = 10 * offset
	add_child(instance)


func spawnModuleX(z, x, offset, name):
	var instance = modules[name].instantiate()
	instance.position.z = z * offset
	instance.position.x = x * offset
	if name == 0:
		var num = rng.randi_range(0,1)
		if num == 1:
			instance.rotation.y = 1.57
	if name == 1:
		var num = rng.randi_range(0,1)
		if num == 0:
			instance.get_node("Tree3").visible = false
		if num == 1:
			instance.get_node("Tree2").visible = false
			
		instance.rotation.y = rng.randi_range(0,360)
	add_child(instance)


func spawnModule(z, x, offset):
	spawnModuleBand(z, offset)
	var instance = modules[0].instantiate()
	instance.position.z = z * offset
	instance.position.x = x * offset
	add_child(instance)
	var num = rng.randi_range(0,5)
	if num == 1:
		instance = modules[num].instantiate()
		instance.position.z = z * offset
		instance.position.x = x * offset
		add_child(instance)
	elif num == 2:
		num = rng.randi_range(0,10)
		if num == 2:
			instance = modules[num].instantiate()
			instance.position.z = z * offset
			instance.position.x = x * offset
			add_child(instance)
	elif num == 4:
		num = rng.randi_range(0,30)
		if num == 4:
			instance = modules[num].instantiate()
			instance.position.z = z * offset
			instance.position.x = x * offset
			add_child(instance)


func PlayerMove(xz):
	var children = get_children()
	if xz == 2 and not collision_check(forward):
		for child in children:
			child.position -= Vector3(0, 0, 2)
		pointsbuffor += 1
	elif xz == 1 and not collision_check(back):
		for child in children:
			child.position += Vector3(0, 0, 2)
		pointsbuffor -= 1
	if pointsbuffor > points:
		points = pointsbuffor
		var num = rng.randi_range(0,1)
		if num == 1:
			num = rng.randi_range(0,1)
			if num == 1:
				path_bufor[path] = 0
				num = rng.randi_range(path,9)
				for i in range(path,num):
					path_bufor[i] = 0
				path = num
				path_bufor[path] = 0
			else:
				path_bufor[path] = 0
				num = rng.randi_range(0,path)
				for i in range(path-num,path):
					path_bufor[i] = 0
					
				path -= num
		else:
			path_bufor[path] = 0
		for i in wight:
			spawnModuleX(29,i,offset,0)
			spawnModuleBand(29,offset)
			if path_bufor[i] == 1:
				spawnModuleX(29,i,offset,1)
			else:
				num = rng.randi_range(0,60)
				if num < 3:
					spawnModuleX(29,i,offset,2)
				if num > 59:
					spawnModuleX(29,i,offset,4)
				if num == 50 and chesttimer > 20:
					spawnModuleX(29,i,offset,5)
					chesttimer = 0
		chesttimer += 1
		path_bufor = [0,0,0,0,0,0,0,0,0,0]
	emit_signal("score", points)


func _process(delta):
	#var children = self.get_children()
	#for child in children:
	var x = get_node("Path3D")
	if x:
		x.get_node("PathFollow3D").progress += delta*10
		#print(x.get_node("PathFollow3D").progress)

	pass

		

func collision_check(direc):
	return direc.is_colliding()
