extends CharacterBody2D

var speed = 400
var accel = 7
@onready var nav = $NavigationAgent2D
@onready var main = $".."


func _physics_process(delta):
	#add gravity
	var direction = Vector3()
	
	nav.target_position = main.chef_target
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()


func _on_navigation_agent_2d_target_reached():
	pass
