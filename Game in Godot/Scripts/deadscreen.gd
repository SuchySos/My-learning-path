extends Control

@onready var control: = $"../"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_relife_pressed():
	control.regen(0,3)
	self.visible = false


func _on_retry_pressed():
	get_tree().change_scene_to_file('res://Scens/main.tscn')


func _on_menu_pressed():
	get_tree().change_scene_to_file('res://Scens/menu.tscn')


func _on_resume_pressed():
	self.visible = false
