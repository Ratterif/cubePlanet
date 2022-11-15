extends KinematicBody

export(bool) var _gravity_on_floor = true
export(bool) var _stop_on_slopes = false
export(bool) var _use_snap = false

var _gravity = 20 #2.10
var _velocity0 = Vector3.ZERO
var _velocity = Vector3.ZERO
var a = Vector3()
var rot_y = 0
var rot_x = 0
var active_item = null
var blocks = []
var poz = Vector3(0,11,0)
var num = 0
var p_poz
var _GV = Vector3(0, -1, 0)
var _vel = Basis()
var lot = Vector2(368, 550)
var active_lot = 0
var picked = false
var target
var timer_use = false
var timer = 0
var flag = false
var ii = 0
var u = Vector3()
var dp = 1
onready var raycast = $cam/RayCast

func rotVec(v: Vector3, b: Basis):
	return Vector3(
		v.x*b.x.x + v.y*b.x.y + v.z*b.x.z, 
		v.x*b.y.x + v.y*b.y.y + v.z*b.y.z, 
		v.x*b.z.x + v.y*b.z.y + v.z*b.z.z
		)

func _ready():
	G.ui = get_node("cam/chest")
	G.Blocks = get_node("../../Platform/KinematicBody/blocks")
	G.Drops = get_node("../../Platform/KinematicBody/drops")
	G.ui.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.center_window()
	world_gen()
	set_item()
	var pickaxe = load("res://pickaxe.tscn").instance()
	get_node("../../Platform/KinematicBody/drops").add_child(pickaxe)
	pickaxe.get_node("KinematicBody").status = "drop"
	pickaxe.get_node("KinematicBody").texture = ""
	pickaxe.get_node("KinematicBody").icon = "res://pickaxe.png"
	pickaxe.translate(Vector3(0, 140, 0))
	var chest = load("res://cube.tscn").instance()
	get_node("../../Platform/KinematicBody/blocks").add_child(chest)
	chest.get_node("KinematicBody").label = "chest"
	chest.get_node("KinematicBody").texture = "res://chest.png"
	chest.get_node("KinematicBody").icon = "res://chest_icon.png"
	chest.get_node("KinematicBody").type = "block"
	chest.get_node("KinematicBody").loader = ""
	chest.get_node("KinematicBody").storage = {26: {'key' : 0, 'count' : 4}, 14: {'key' : 3, 'count' : 1}}
	var mesh = chest.get_node("KinematicBody/MeshInstance")
	var mat = SpatialMaterial.new()
	mat.albedo_texture = load(chest.get_node("KinematicBody").texture)
	mesh.material_override = mat
	chest.get_node("KinematicBody").key = 3
	chest.translate(Vector3(1, 25, 1))
	var axe = load("res://axe.tscn").instance()
	get_node("../../Platform/KinematicBody/drops").add_child(axe)
	axe.get_node("KinematicBody").status = "drop"
	axe.get_node("KinematicBody").texture = ""
	axe.get_node("KinematicBody").icon = "res://axe.png"
	axe.translate(Vector3(0, 140, 10))
	var torch = load("res://torch.tscn").instance()
	get_node("../../Platform/KinematicBody/drops").add_child(torch)
	torch.get_node("KinematicBody").status = "drop"
	torch.get_node("KinematicBody").texture = ""
	torch.get_node("KinematicBody").icon = "res://torch.png"
	torch.translate(Vector3(0, 140, 10))
	add(0, 'dirt', 62, "res://dirt.png", "res://dirt_icon.png", "block", "")
	add(1, 'rock', 20, "res://rock.png", "res://rock_icon.png", "block", "")
func add(key, label, count, texture, icon, type, loader):
	var item = G.add(key, label, count, texture, icon, type, loader)
	set_item()
	if !item:
		drop_out(key, label, count, texture, icon, type, loader)
func world_gen():
	for x in range(-24, 24):
		for y in range(-24, 24):
			for z in range(-24, 24):
				if (x > 20 or x < -20 or y > 20 or y < -20 or z > 20 or z< -20) and ((x % 2 == 1 or -x % 2 == 1) and (y % 2 == 1 or -y % 2 == 1) and (z % 2 == 1 or -z % 2 == 1)):
					if randf() < 0.1:
						var id = randi() % 3
						var block = load("res://cube.tscn").instance()
						var item = block.get_node("KinematicBody")
						blocks.append(block)
						#add_child_below_node(get_tree().get_root().get_node("item"), block)
						get_node("../../Platform/KinematicBody/blocks").add_child(block)
						block.translate(Vector3(x, y, z))
						item.label = G.conf[id].label
						item.texture = G.conf[id].texture
						item.icon = G.conf[id].icon
						item.count = G.conf[id].count
						var mesh = item.get_node("MeshInstance")
						var mat = SpatialMaterial.new()
						mat.albedo_texture = load(item.texture)
						mesh.material_override = mat
						item.key = id


func _physics_process(delta):
	var base = Basis(Vector3(), PI/2)
	p_poz = global_transform.origin
	var snap = Vector3.DOWN * 0.2
	var v = Vector3(0, 0, 0);
	if Input.is_action_just_pressed('ui_1'):
		change_lot(0)
	if Input.is_action_just_pressed('ui_2'):
		change_lot(1)
	if Input.is_action_just_pressed('ui_3'):
		change_lot(2)
	if Input.is_action_just_pressed('ui_4'):
		change_lot(3)
	if Input.is_action_just_pressed('ui_5'):
		change_lot(4)
	if Input.is_action_just_pressed('ui_6'):
		change_lot(5)
	if Input.is_action_just_pressed('ui_7'):
		change_lot(6)
	if Input.is_action_just_pressed('ui_8'):
		change_lot(7)
	if Input.is_action_just_pressed('ui_9'):
		change_lot(8)
	$cam/Control/Active.transform.origin = Vector2(lot.x + active_lot * 50, lot.y)

	if Input.is_action_pressed('ui_right'):
		v.x = 6
	if Input.is_action_pressed('ui_left'):
		v.x = -6
	if Input.is_action_pressed('ui_up'):
		v.z = -6
	if Input.is_action_pressed('ui_down'):
		v.z = 6
	if Input.is_action_pressed('ui_accept') and (is_on_floor() or is_on_wall() or is_on_ceiling()):
		v.y = 10
		_velocity0.y = v.y
	if Input.is_action_pressed('ui_LMB'):
		var colide = raycast.get_collider()
		if colide and colide.get_script() and colide.has_method('action'):
			if colide.status == "stand":
				if timer_use:
					if target != colide:
						timer_use = false
						timer = 0
				target = colide
				if timer_use:
					if timer >= G.conf[target.key].time:
						var level = 0
						if G.has(active_lot):
							if G.conf[G.all[active_lot].key].type == "tool":
								if G.conf[G.all[active_lot].key].break_type == G.conf[target.key].break_type: 
									level = G.conf[G.all[active_lot].key].level
						if level >= G.conf[target.key].level:
							var drop = load("res://cube.tscn").instance()
							get_node("../../Platform/KinematicBody/drops").add_child(drop)
							drop.translate(raycast.get_collision_point()*5)
							var item = drop.get_node("KinematicBody")
							item.status = "drop"
							item.label = target.label
							item.texture = target.texture
							item.icon = target.icon
							item.count = target.count
							var mesh = item.get_node("MeshInstance")
							var mat = SpatialMaterial.new()
							mat.albedo_texture = load(target.texture)
							mesh.material_override = mat
							item.key = target.key
						if target.storage:
							target.call("drop")
						else: G.Blocks.remove_child(target.get_node("../"))
						timer_use = false
						timer = 0
				if timer_use:
					var c = 1
					if G.has(active_lot):
						if G.conf[G.all[active_lot].key].type == "tool":
							if G.conf[G.all[active_lot].key].break_type == G.conf[target.key].break_type:
								c = G.conf[G.all[active_lot].key].boost
					timer += delta * c
				if !timer_use:
					if target:
						timer_use = true
				if G.all.has(active_lot):
					if G.conf[G.all[active_lot].key].type == "tool":
						active_item.get_node("KinematicBody").animation()
			if colide.status == "drop":
				add(colide.key, colide.label, colide.count, colide.texture, colide.icon, colide.type, colide.loader)
				get_node("../../Platform/KinematicBody/drops").remove_child(colide.get_node("../"))
				set_item()
	elif timer_use:
		timer_use = false
		timer = 0
	if Input.is_action_pressed('ui_sprint'):
		v.x = v.x * 2
		v.z = v.z * 2
	_velocity0.x = v.x
	_velocity0.z = v.z
	
	if Input.is_action_just_pressed('ui_RMB'):
		if raycast.get_collider() and raycast.get_collider().has_method('action') and raycast.get_collider().type == "block" and typeof(raycast.get_collider().storage) == 18 and typeof(G.chest) == 0:
			G.set_chest(raycast.get_collider().storage)
		else: spawn_block(active_lot)
	if Input.is_action_just_pressed('ui_drop'):
		drop_item(active_lot)
	
	if Input.is_action_just_pressed("ui_cancel"):
		if typeof(G.chest) == 18:
			G.chest = null
			G.moving = null
			G.ui.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else: get_tree().quit()

	transform.basis = Basis() * _vel.inverse()
	
	if !is_on_floor() and !is_on_wall() and !is_on_ceiling():
		_velocity0 += Vector3(0, -1, 0) * _gravity * delta


	_velocity = rotVec(_velocity0, _vel)

	var d = G.get_side(p_poz)


	if (d == 2 and dp == 1 or d == 1 and dp == 3 or d == 6 and dp == 2 or d == 3 and dp == 6) and !flag:
		u = Vector3(0,0,-1)
		flag =true
		ii = 0
		dp = d
	if (d == 1 and dp == 2 or d == 3 and dp == 1 or d == 6 and dp == 3 or d == 2 and dp == 6) and !flag:
		u = Vector3(0,0,1)
		flag =true
		ii = 0
		dp = d
	if (d == 4 and dp == 1 or d == 1 and dp == 5 or d == 6 and dp == 4 or d == 5 and dp == 6) and !flag:
		u = Vector3(1,0,0)
		flag =true
		ii = 0
		dp = d
	if (d == 1 and dp == 4 or d == 5 and dp == 1 or d == 6 and dp == 5 or d == 4 and dp == 6) and !flag:
		u = Vector3(-1,0,0)
		flag =true
		ii = 0
		dp = d
	if (d == 4 and dp == 2 or d == 5 and dp == 3 or d == 3 and dp == 4 or d == 2 and dp == 5) and !flag:
		u = Vector3(0,1,0)
		flag =true
		ii = 0
		dp = d
	if (d == 5 and dp == 2 or d == 4 and dp == 3 or d == 2 and dp == 4 or d == 3 and dp == 5) and !flag:
		u = Vector3(0,-1,0)
		flag =true
		ii = 0
		dp = d

	if flag:
		ii += 1
		if ii <= 10:
			_vel =  _vel * Basis().rotated(u, PI/20)
		else:
			flag = false



	rot_y = 0
	if _use_snap:
		_velocity = move_and_slide_with_snap(_velocity, snap, Vector3.UP, _stop_on_slopes)
	else:
		_velocity = move_and_slide(_velocity, -_GV, _stop_on_slopes)

func _input(e):
	if e is InputEventMouseMotion:
		if typeof(G.chest) != 18:
			rot_y += e.relative.x * 0.01
			rot_x += e.relative.y * 0.01
			_vel = Basis().rotated(Vector3(0,1,0), rot_y) * _vel
			rot_y = 0
			if rot_x > PI/3:
				rot_x = PI/3
			if rot_x < -PI/3:
				rot_x = -PI/3
			$cam.transform.basis = Basis(Vector3(-1,0,0), rot_x)

func set_item():
	if active_item:
		$cam/item.remove_child(active_item)
		active_item = null
	if G.all.has(active_lot):
		if G.conf[G.all[active_lot].key].type == 'block':
			active_item = load("res://cube.tscn").instance()
			var mat2 = SpatialMaterial.new()
			mat2.albedo_texture = load(G.conf[G.all[active_lot].key].texture)
			active_item.get_node("KinematicBody/MeshInstance").material_override = mat2
			$cam/item.add_child(active_item)
		else:
			active_item = load(G.conf[G.all[active_lot].key].loader).instance()
			$cam/item.add_child(active_item)
func spawn_block(num):
	if G.has(num) and G.conf[G.all[num].key].type == "block":
		var block = load("res://cube.tscn").instance()
		var item = block.get_node("KinematicBody")
		blocks.append(block)
		#add_child_below_node(get_tree().get_root().get_node("item"), block)
		get_node("../../Platform/KinematicBody/blocks").add_child(block)
		var forw = raycast.get_collision_point()
		#block.translate(Vector3(round(forw.x/-2)*2, round(forw.y/2)*2, round(forw.z/2)*2))
		block.translate(Vector3(round((forw.x-1)/2)*2+1,round((forw.y-1)/2)*2+1,round((forw.z-1)/2)*2+1))
		item.label = G.conf[G.all[num].key].label
		item.texture = G.conf[G.all[num].key].texture
		item.icon = G.conf[G.all[num].key].icon
		item.count = G.conf[G.all[num].key].count
		item.type = "block"
		item.loader = ""
		var mesh = item.get_node("MeshInstance")
		var mat = SpatialMaterial.new()
		mat.albedo_texture = load(item.texture)
		mesh.material_override = mat
		item.key = G.all[num].key
		G.remove(num, 1)
		set_item()
#		poz.y += 2
func drop_item(num):
	if G.has(num):
		var drop
		if G.conf[G.all[num].key].type == "block":
			drop = load("res://cube.tscn").instance()
		else:
			drop = load(G.conf[G.all[num].key].loader).instance()
		var item = drop.get_node("KinematicBody")
		#add_child_below_node(get_tree().get_root().get_node("item"), block)
		get_node("../../Platform/KinematicBody/drops").add_child(drop)
		#block.translate(Vector3(round(forw.x/-2)*2, round(forw.y/2)*2, round(forw.z/2)*2))
		var poz = p_poz + rotVec(Vector3.DOWN, _vel) * 5
		drop.translate(poz*5)
		item.status = "drop"
		item.label = G.conf[G.all[num].key].label
		item.texture = G.conf[G.all[num].key].texture
		item.icon = G.conf[G.all[num].key].icon
		item.count = G.conf[G.all[num].key].count
		item.type = G.conf[G.all[num].key].type
		item.loader = G.conf[G.all[num].key].loader
		if G.conf[G.all[num].key].type == "block":
			var mesh = item.get_node("MeshInstance")
			var mat = SpatialMaterial.new()
			mat.albedo_texture = load(item.texture)
			mesh.material_override = mat
		item.key = G.all[num].key
		G.remove(num, 1)
		set_item()
#		poz.y += 2
func drop_out(key, label, count, texture, icon, type, loader):
	var drop
	if type == "block":
		drop = load("res://cube.tscn").instance()
	else:
		drop = load(loader).instance()
	var item = drop.get_node("KinematicBody")
	#add_child_below_node(get_tree().get_root().get_node("item"), block)
	get_node("../../Platform/KinematicBody/drops").add_child(drop)
	#block.translate(Vector3(round(forw.x/-2)*2, round(forw.y/2)*2, round(forw.z/2)*2))
	var poz = p_poz + rotVec(Vector3.DOWN, _vel) * 5
	drop.translate(Vector3(poz)*5)
	item.status = "drop"
	item.label = label
	item.texture = texture
	item.icon = icon
	item.count = count
	item.type = type
	item.loader = loader
	if type == "block":
		var mesh = item.get_node("MeshInstance")
		var mat = SpatialMaterial.new()
		mat.albedo_texture = load(item.texture)
		mesh.material_override = mat
	item.key = key
#		poz.y += 2
func change_lot(num):
	active_lot = num
	set_item()
