extends KinematicBody

export var key = 0
export var label = ""
export var count = 1
export(Texture) var texture
export(Texture) var icon
export var status = "stand"
var v = Vector3()
var vec =Vector3.DOWN
var p_poz

#func _process(delta):
#	if status == "drop":
#		$AnimationPlayer.play("drop")
#	if label = "chest":
#		add_child()
func _physics_process(delta):
	if status == "drop":
		p_poz = global_transform.origin
		var d = G.get_side(p_poz)
		if d == 1:
			vec = Vector3.DOWN
		if d == 6:
			vec = Vector3.UP
		if d == 4:
			vec = Vector3.BACK
		if d == 5:
			vec = Vector3.FORWARD
		if d == 2:
			vec = Vector3.RIGHT
		if d == 3:
			vec = Vector3.LEFT
		if !is_on_floor() and !is_on_wall() and !is_on_ceiling():
			v += vec * 20 * delta
		else:
			v = Vector3()

		v = move_and_slide(v, vec, false)

func action():
	print("Action", key)
#	G.global.add(key, label, count, texture, icon)
	G.add(key, label, count, texture, icon)
	print(G.all)
