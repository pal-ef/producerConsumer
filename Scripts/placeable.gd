extends StaticBody2D

@export var has_item: bool = false
@onready var item = $Item

func place_item():
	if not has_item:
		has_item = true
		item.visible = true

func remove_item():
	has_item = false
	item.visible = false

func has_food() -> bool:
	return has_item
