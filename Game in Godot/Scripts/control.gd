extends Control

@onready var level: = $"../SubViewport/GridMap"
@onready var scoreInfoLabel: = $scoreinfo/Label 
@onready var animator = $"../SubViewport/player/AnimationPlayer"
@onready var camera: = $"../SubViewport/player/Camera3D"
signal Buttonpress
signal UsableFire

var HpTexture = preload("res://Scens/hp.tscn")
var HpContainer = []
var ManaTexture = preload("res://Scens/mana.tscn")
var ManaContainer = []
var EnergyTexture = preload("res://Scens/energy.tscn")
var EnergyContainer = []
var UsableTexture = preload("res://Scens/bomb.tscn")
var UsableContainer = []
var Bomb3d = preload("res://Scens/bomb3d.tscn")
var Path3d = preload("res://Scens/path3d.tscn")
var state = false
var StatsContainer = [4,3,4]

# Called when the node enters the scene tree for the first time.
func _ready():
	if level:
		level.connect('score', scorecounter)
		camera.connect('usablewasted', usablewasted)
		#level.find_children()
	
	for i in range(4):
		var newTextureRect = HpTexture.instantiate()
		$"infoBox/BoxHp".add_child(newTextureRect)
		HpContainer.append(newTextureRect)
	for i in range(3):
		var newTextureRect = ManaTexture.instantiate()
		$"infoBox/BoxMana".add_child(newTextureRect)
		ManaContainer.append(newTextureRect)
	for i in range(4):
		var newTextureRect = EnergyTexture.instantiate()
		$"infoBox/BoxEnergy".add_child(newTextureRect)
		EnergyContainer.append(newTextureRect)
	for i in range(5):
		var newTextureRect = UsableTexture.instantiate()
		#$"usableBox/usableTexture".add_child(newTextureRect)
		var instance = Bomb3d.instantiate()
		instance.position.z = -12.2 + (i*0.41)
		instance.position.x = -2.5 - (i*1.1)
		instance.position.y = 7.8
		$"../SubViewport/player".add_child(instance)
		UsableContainer.append(instance)


func usablewasted(counter, pos):
	if UsableContainer.size() > 0:
		var toRemove = UsableContainer.pop_back()
		UsableContainer.is_empty()
		toRemove.queue_free()
		var instance = Path3d.instantiate()
		instance.curve.set_point_position(0,Vector3(-2.5+$"../SubViewport/player".position.x,7.8,-12.2))
		instance.curve.set_point_position(1,pos)
		instance.curve.set_point_out(1,Vector3(0,0,0))
		instance.curve.set_point_out(0,Vector3(0,3,0))
		instance.curve.set_point_in(1,Vector3(0,2,0))
		print(instance.curve.get_point_position(0))
		print(instance.curve.get_point_position(1))
		print(pos)
		level.add_child(instance)
		print("dodal")
		#level.add_child(instance)


func gethit(dmg):
	for i in range(dmg):
		if HpContainer.size() > 0:
			var toRemove = HpContainer.pop_back()
			HpContainer.is_empty()
			toRemove.queue_free()
		if HpContainer.size() < 1:
			$Deadscreen.visible = true
			$Deadscreen/Panel/VBoxContainer/Relife.visible = true
			$Deadscreen/Panel/VBoxContainer/Resume.visible = false
			state = false


func regen(atr, count):
	if atr == 0:
		for i in range(count):
			if StatsContainer[0] > HpContainer.size():
				var newTextureRect = HpTexture.instantiate()
				$"infoBox/BoxHp".add_child(newTextureRect)
				HpContainer.append(newTextureRect)
	if atr == 1:
		for i in range(count):
			var newTextureRect = ManaTexture.instantiate()
			$"infoBox/BoxMana".add_child(newTextureRect)
			ManaContainer.append(newTextureRect)
	if atr == 2:
		for i in range(count):
			var newTextureRect = EnergyTexture.instantiate()
			$"infoBox/BoxEnergy".add_child(newTextureRect)
			EnergyContainer.append(newTextureRect)


func scorecounter(points):
	if scoreInfoLabel:
		if points > 9999:
			scoreInfoLabel.label_settings.font_size = 30
		scoreInfoLabel.text = str(points)


#func _on_button_lu_pressed():
	#if not animator.is_playing():
		#var xz = 0
		#emit_signal("Buttonpress", xz)
		#print("LU ok")
#
#
#func _on_button_ld_pressed():
	#if not animator.is_playing():
		#var xz = 1
		#emit_signal("Buttonpress", xz)
		#print("LD ok")
#
#
#func _on_button_ru_pressed():
	#if not animator.is_playing():
		#var xz = 2
		#emit_signal("Buttonpress", xz)
		#print("RU ok")
#
#
#func _on_button_rd_pressed():
	#if not animator.is_playing():
		#var xz = 3
		#emit_signal("Buttonpress", xz)
		#print("RD ok")


func _on_button_lu_button_down():
	state = true
	while state:
		if not animator.is_playing():
			var xz = 0
			emit_signal("Buttonpress", xz)
		await get_tree().create_timer(0.12).timeout


func _on_button_lu_button_up():
	state = false


func _on_button_ld_button_down():
	state = true
	while state:
		if not animator.is_playing():
			var xz = 1
			emit_signal("Buttonpress", xz)
		await get_tree().create_timer(0.12).timeout


func _on_button_ld_button_up():
	state = false


func _on_button_ru_button_down():
	state = true
	while state:
		if not animator.is_playing():
			var xz = 2
			emit_signal("Buttonpress", xz)
		await get_tree().create_timer(0.12).timeout


func _on_button_ru_button_up():
	state = false


func _on_button_rd_button_down():
	state = true
	while state:
		if not animator.is_playing():
			var xz = 3
			emit_signal("Buttonpress", xz)
		await get_tree().create_timer(0.12).timeout


func _on_button_rd_button_up():
	state = false


func _on_menu_pressed():
	$Deadscreen.visible = true
	$Deadscreen/Panel/VBoxContainer/Resume.visible = true
	$Deadscreen/Panel/VBoxContainer/Relife.visible = false


func _on_button_1_pressed():
	if UsableTexture:
		emit_signal("UsableFire")
		print("ready")
