extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	G.control = [
	]
	G.labels = [
	]
	for n in range(9):
		var lot = preload("res://lot.tscn").instance()
		lot.connect('gui_input', self, 'on_input_item', [lot, n])
		print("connn ", lot)
		add_child(lot)
		lot.rect_position = Vector2(n*50, 0)
		G.control.append(lot.get_node("Lot/item"))
		G.labels.append(lot.get_node("Lot/Label"))

func on_input_item(e, item, key):
	if e is InputEventMouseButton:
		if e.pressed:
			if !G.moving:
				if G.all.has(key):
					G.moving = {'type': "self", 'content' : G.all[key], 'lot': key}
			else:
				G.move({'type': "self", 'lot': key})

	# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

