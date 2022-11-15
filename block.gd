extends KinematicBody

export var key = 0
export var label = ""
export var count = 1
export(Texture) var texture
export(Texture) var icon
export var status = "stand"
export var type = "block"
export var loader = ""
export({}) var storage = null
var v = Vector3()
var vec =Vector3.DOWN
var p_poz = global_transform.origin

#func _process(delta):
#	if status == "drop":
#		$AnimationPlayer.play("drop")
#	if label = "chest":
#		add_child()
func _physics_process(delta):
	p_poz = global_transform.origin
	if label == "chest" and typeof(storage) != 18:
		storage = {}
	if status == "drop":
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
func drop():
	for n in range(27):
		if storage.has(n):
			var drop
			if G.conf[storage[n].key].type == "block":
				drop = load("res://cube.tscn").instance()
			else: drop = load(G.conf[storage[n].key].loader).instance()
			var item = drop.get_node("KinematicBody")
			G.Drops.add_child(drop)
			drop.translate(p_poz*5)
			item.status = "drop"
			item.label = G.conf[storage[n].key].label
			item.texture = G.conf[storage[n].key].texture
			item.icon = G.conf[storage[n].key].icon
			item.count = storage[n].count
			item.type = G.conf[storage[n].key].type
			item.loader = G.conf[storage[n].key].loader
			if G.conf[storage[n].key].type == "block":
				var mesh = item.get_node("MeshInstance")
				var mat = SpatialMaterial.new()
				mat.albedo_texture = load(item.texture)
				mesh.material_override = mat
			item.key = storage[n].key
	G.Blocks.remove_child(get_node("../"))

