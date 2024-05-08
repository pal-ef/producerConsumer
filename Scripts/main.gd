extends Node2D
@onready var placeables = $Placeables
@onready var label = $CanvasLayer/MarginContainer/Label
@onready var chef_default_position = $ChefDefaultPosition
@onready var consumer_default_position = $ConsumerDefaultPosition
@onready var message_timer = $MessageTimer
@onready var status_chef = $CanvasLayer/MarginContainer2/StatusChef
@onready var status_consumidor = $CanvasLayer/MarginContainer3/StatusConsumidor

var turn: int 
var placeables_array: Array[Node]

# Positioning
var last_placed_idx: int = 0
var last_place_where_ate_idx: int = 0
var chef_target: Vector2
var consumer_target: Vector2

# Counters
var n_pizzas_to_place: int = 0
var n_pizzas_placed: int = 0

var n_pizzas_to_eat: int = 0
var n_pizzas_eaten: int = 0

func _ready():
	placeables_array = placeables.get_children()
	chef_target = chef_default_position.global_position
	consumer_target = consumer_default_position.global_position
	decide_turn()
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func decide_turn() -> void:
	turn = randi_range(0, 1)
	if (turn == 0):
		# Chef's turn
		chef_turn_start()
		label.text = "Turno del productor"
		status_chef.text = "Produciendo"
		status_consumidor.text = "Mimiendo"
	else:
		# Consumer's turn
		consumer_turn_start()
		label.text = "Turno del consumidor"
		status_consumidor.text = "Produciendo"
		status_chef.text = "Mimiendo"

func get_target(idx: int):
	return placeables_array[idx]

func chef_redirect_to_target() -> void:
	# set target
	chef_target = get_target(last_placed_idx).global_position + Vector2(0, -75)
	
func consumer_redirect_to_target() -> void:
	# set target
	consumer_target = get_target(last_place_where_ate_idx).global_position + Vector2(0, -75)
	
func chef_turn_start():
	# set number of items to place
	n_pizzas_placed = 0
	n_pizzas_to_place = randi_range(3, 6)
	# move to target
	chef_redirect_to_target()
	
func consumer_turn_start():
	if get_target(last_place_where_ate_idx).has_food():
		# set number of items to place
		n_pizzas_eaten = 0
		n_pizzas_to_eat = randi_range(3, 6)
		# move to target
		consumer_redirect_to_target()
	else:
		consumer_turn_end()


func chef_increase_last_position_idx() -> void:
	last_placed_idx += 1
	
	if last_placed_idx > 21:
		last_placed_idx = 0

func consumer_increase_last_position_idx() -> void:
	last_place_where_ate_idx += 1
	
	if last_place_where_ate_idx > 21:
		last_place_where_ate_idx = 0


func chef_turn_end():
	turn = -99
	# set default target
	chef_target = chef_default_position.global_position

func consumer_turn_end():
	turn = -100
	# set default target
	consumer_target = consumer_default_position.global_position

func _on_navigation_agent_2d_target_reached():
	if chef_target != chef_default_position.global_position:
		# Place item
		get_target(last_placed_idx).place_item()
		n_pizzas_placed += 1
		
		chef_increase_last_position_idx()
		
		if n_pizzas_placed < n_pizzas_to_place:
			if not get_target(last_placed_idx).has_food():
				chef_redirect_to_target()
			else:
				status_chef.text = "Tiene comida!"
				chef_turn_end()
				last_placed_idx -= 1
				if last_placed_idx < 0:
					last_placed_idx = 21
		else:
			chef_turn_end()
	elif turn == -99:
		decide_turn()

func _on_consumer_nav_agent_target_reached():
	if consumer_target != consumer_default_position.global_position:
		# Place item
		get_target(last_place_where_ate_idx).remove_item()
		n_pizzas_eaten += 1
		
		consumer_increase_last_position_idx()
		
		if n_pizzas_eaten < n_pizzas_to_eat:
			if get_target(last_placed_idx).has_food():
				consumer_redirect_to_target()
			else:
				consumer_turn_end()
		else:
			consumer_turn_end()
	elif turn == -100:
		decide_turn()
