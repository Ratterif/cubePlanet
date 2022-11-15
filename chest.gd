extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	G.C_control = [
	]
	G.C_labels = [
	]
	for m in range(3):
		for n in range(9):
			var lot = preload("res://lot.tscn").instance()
			lot.connect('gui_input', self, 'on_input_item', [lot, n+m*9])
			add_child(lot)
			lot.rect_position = Vector2(11+n*50, 10+ m*50)
			G.C_control.append(lot.get_node("Lot/item"))
			G.C_labels.append(lot.get_node("Lot/Label"))
func on_input_item(e, item, key):
	if e is InputEventMouseButton:
		if e.pressed:
			if typeof(G.chest) == 18:
				if !G.moving:
					if G.chest.has(key):
						G.moving = {'type': "chest", 'content' : G.chest[key], 'lot': key}
				else:
					G.move({'type': "chest", 'lot': key})
	
	# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

