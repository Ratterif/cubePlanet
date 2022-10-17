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

var flag = false
var ii = 0
var u = Vector3()
var dp = 1

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
		if(!active_item):
			set_item("res://pickaxe.tscn")
		else:
			set_item(null)
		print(active_item)
	if Input.is_action_pressed('ui_LMB'):
		if(active_item):
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
		if rot_x > PI/2:
			rot_x = PI/2
		if rot_x < -PI/2:
			rot_x = -PI/2
	$cam.transform.basis = Basis(Vector3(-1,0,0), rot_x)

func set_item(path):
	if !path:
		$cam/item.remove_child(active_item)
		active_item = null
	else:
		active_item = load(path).instance()
		$cam/item.add_child(active_item)

func spawn_block():
	var block = load("res://cube.tscn").instance()
	blocks.append(block)
	#add_child_below_node(get_tree().get_root().get_node("item"), block)
	get_node("../../Platform/KinematicBody/blocks").add_child(block)
	var forw = p_poz + rotVec(Vector3(0,0,-1), _vel)
	block.translate(Vector3(round(forw.x/2)*2, round(forw.y/2)*2, round(forw.z/2)*2))
#	poz.y += 2
	
