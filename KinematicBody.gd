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
var lot = Vector2(354, 535)
var active_lot = 0
var picked = false

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
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var base = Basis(Vector3(), PI/2)
	p_poz = global_transform.origin
	var snap = Vector3.DOWN * 0.2
	var v = Vector3(0, 0, 0);

	if Input.is_action_pressed('ui_1'):
		change_lot(0)
	if Input.is_action_pressed('ui_2'):
		change_lot(1)
	if Input.is_action_pressed('ui_3'):
		change_lot(2)
	if Input.is_action_pressed('ui_4'):
		change_lot(3)
	if Input.is_action_pressed('ui_5'):
		change_lot(4)
	if Input.is_action_pressed('ui_6'):
		change_lot(5)
	if Input.is_action_pressed('ui_7'):
		change_lot(6)
	if Input.is_action_pressed('ui_8'):
		change_lot(7)
	if Input.is_action_pressed('ui_9'):
		change_lot(8)
	$cam/Control/Active.transform.origin = Vector2(lot.x + active_lot * 50, lot.y)

	if Input.is_action_pressed('ui_right'):
		v.x = 10
	if Input.is_action_pressed('ui_left'):
		v.x = -10
	if Input.is_action_pressed('ui_up'):
		v.z = -10
	if Input.is_action_pressed('ui_down'):
		v.z = 10
	if Input.is_action_pressed('ui_accept') and (is_on_floor() or is_on_wall() or is_on_ceiling()):
		v.y = 20
		_velocity0.y = v.y
	if Input.is_action_just_pressed('ui_item'):
		if(!picked):
			picked = true
			G.add(2, 'pickaxe', 1, '', "res://pickaxe.png")
		else:
			picked = false
			G.remove(2, -1)
		set_item()
		print(G.all)
	if Input.is_action_pressed('ui_LMB'):
		if(active_item):
			var colide = raycast.get_collider()
			if colide and colide.get_script() and colide.has_method('action'):
				print (colide.texture)
				colide.call("action")
				get_node("../../Platform/KinematicBody/blocks").remove_child(colide.get_node("../"))
			active_item.animation()
	if Input.is_action_pressed('ui_sprint'):
		v.x = v.x * 2
		v.z = v.z * 2
	_velocity0.x = v.x
	_velocity0.z = v.z
	
	if Input.is_action_just_pressed('ui_RMB'):
		spawn_block()
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	transform.basis = Basis() * _vel.inverse()
	
	if !is_on_floor() and !is_on_wall() and !is_on_ceiling():
		_velocity0 += Vector3(0, -1, 0) * _gravity * delta

	var d1 = (p_poz.x + p_poz.y) / sqrt(2)
	var d2 = (p_poz.x - p_poz.y) / sqrt(2)
	var d3 = (p_poz.z + p_poz.y) / sqrt(2)
	var d4 = (p_poz.z - p_poz.y) / sqrt(2)
	var d5 = (p_poz.z + p_poz.x) / sqrt(2)
	var d6 = (p_poz.z - p_poz.x) / sqrt(2)
	#print (d4, " ", p_poz.x, " ", p_poz.y, " ", p_poz.z)

	_velocity = rotVec(_velocity0, _vel)

	var d

	if d1 >0 and d2 < 0 and d3 > 0 and d4<0:
		d = 1
	if d1 <0 and d2 < 0 and d5< 0 and d6> 0:
		d = 2
	if d1 >0 and d2 > 0 and d5 > 0 and d6<0:
		d = 3
	if d1 <0 and d2 > 0 and d3 < 0 and d4>0:
		d = 6
	if d3 <0 and d4 < 0 and d5 < 0 and d6<0:
		d = 4
	if d3 >0 and d4 > 0 and d5 > 0 and d6>0:
		d = 5

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
		print("bbb")
		$cam/item.remove_child(active_item)
		active_item = null
	print(G.all.has(active_lot))
	if G.all.has(active_lot):
		if G.all[active_lot].label == 'pickaxe':
			active_item = load("res://pickaxe.tscn").instance()
			$cam/item.add_child(active_item)
		else:
			active_item = load("res://cube.tscn").instance()
			active_item.get_node("KinematicBody/MeshInstance").get_active_material(0).normal_texture = load(G.all[active_lot].texture)
			$cam/item.add_child(active_item)

func spawn_block():
	var block = load("res://cube.tscn").instance()
	var item = block.get_node("KinematicBody")
	blocks.append(block)
	#add_child_below_node(get_tree().get_root().get_node("item"), block)
	get_node("../../Platform/KinematicBody/blocks").add_child(block)
	var forw = raycast.get_collision_point()
	#block.translate(Vector3(round(forw.x/-2)*2, round(forw.y/2)*2, round(forw.z/2)*2))
	block.translate(Vector3(round((forw.x-1)/2)*2+1,round((forw.y-1)/2)*2+1,round((forw.z-1)/2)*2+1))
	item.label = "dirt"
	item.texture = "res://dirt.png"
	item.icon = "res://dirt_icon.png"
	var mesh = item.get_node("MeshInstance")
	var mat = mesh.get_active_material(0)
	var tex = load("res://dirt.png") 
	mat.normal_texture = tex
	item.key = 0
#	poz.y += 2
func change_lot(num):
	active_lot = num
	set_item()
