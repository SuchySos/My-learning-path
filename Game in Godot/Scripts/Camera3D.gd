extends Camera3D


@onready var control: = $"../../../Control"

var bufor = false

signal usablewasted(counter)


# Called when the node enters the scene tree for the first time.
func _ready():
	if control:
		control.connect('UsableFire', buforon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func buforon():
	control.get_node("ButtonCon").visible = false
	#print("odebrało")
	bufor = true


func _input(event):
	if event.is_action_pressed("click") and bufor:
		#print("strzelam")
		shoot_ray()
	if event.is_action_released("click"):
		var pos = event.position
		#print(pos, bufor)
		

func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_lenght = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_lenght
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_results = space.intersect_ray(ray_query)
	#print(raycast_results)
	if raycast_results:
		#print(raycast_results)
		#print(raycast_results.collider)
		var node = get_node(raycast_results.collider.get_path())
		#print(node)
		change_texture_on_object(node,1)
		bufor = false
		emit_signal("usablewasted", 1, raycast_results.position)
		#control.visible = true
		#node.queue_free()
	control.get_node("ButtonCon").visible = true


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
