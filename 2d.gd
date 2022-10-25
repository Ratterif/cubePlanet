extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	G.control = [
		$Lot/item,
		$Lot2/item,
		$Lot3/item
	]
	G.labels = [
		$Lot/Label,
		$Lot2/Label,
		$Lot3/Label
	]
	# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

