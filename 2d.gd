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
	for n in range(0, 9):
		var lot = load("res://lot.tscn").instance()
		add_child(lot)
		lot.get_node("Lot").transform.origin = Vector2(354+n*50, 535)
		G.control.append(lot.get_node("Lot/item"))
		print(G.control)
		G.labels.append(lot.get_node("Lot/Label"))
	G.add(0, 'dirt', 16, "res://dirt.png", "res://dirt_icon.png")
	G.add(1, 'rock', 20, "res://rock.png", "res://rock_icon.png")

	# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

