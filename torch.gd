extends KinematicBody

export var key = 6
export var label = "torch"
export var count = 1
export(Texture) var texture
export(Texture) var icon
export var status = "use"
export var type = "item"
export var loader = "res://torch.tscn"
var v = Vector3()
var vec =Vector3.DOWN
var p_poz

func animation():
	if status == "use":
		$AnimationPlayer.play("chop")
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
	pass

