extends Node

var all = {}
var conf = {
	0: {'label': 'dirt', 'count': 1, 'texture': "res://dirt.png", 'icon': "res://dirt_icon.png", 'type': "block", 'loader': "", 'time': 1.5, 'level': 0, 'break_type': "shovel", 'max': 64},
	1: {'label': 'rock', 'count': 1, 'texture': "res://rock.png", 'icon': "res://rock_icon.png", 'type': "block", 'loader': "", 'time': 5, 'level': 3, 'break_type': "pickaxe", 'max': 64},
	2: {'label': 'wood', 'count': 1, 'texture': "res://wood.png", 'icon': "res://wood_icon.png", 'type': "block", 'loader': "", 'time': 3, 'level': 0, 'break_type': "axe", 'max': 64},
	3: {'label': 'chest', 'count': 1, 'texture': "res://chest.png", 'icon': "res://chest_icon.png", 'type': "block", 'loader': "", 'time': 4, 'level': 0, 'break_type': "axe", 'max': 64},
	4: {'label': 'pickaxe', 'count': 1, 'texture': "", 'icon': "res://pickaxe.png", 'type': "tool", 'loader': "res://pickaxe.tscn", 'level': 3, 'break_type': "pickaxe", 'boost': 2, 'max': 1},
	5: {'label': 'axe', 'count': 1, 'texture': "", 'icon': "res://axe.png", 'type': "tool", 'loader': "res://axe.tscn", 'level': 3, 'break_type': "axe", 'boost': 2.5, 'max': 1},
	6: {'label': 'torch', 'count': 1, 'texture': "", 'icon': "res://torch.png", 'type': "item", 'loader': "res://torch.tscn", 'max': 1}
}
var ui
var Blocks
var Drops
var control
var labels
var C_control
var C_labels
var moving = null
var chest = null
var maximize = OS.is_window_maximized()
func _process(delta):
	if !maximize:
		OS.set_window_maximized(true)
func move(item):
	var typedI = chest if item.type == "chest" else (all if item.type == "self" else null)
	var typedM = chest if moving.type == "chest" else (all if moving.type == "self" else null)
	if typedI.has(item.lot) and moving.content.key == typedI[item.lot].key:
		if moving.content.count + typedI[item.lot].count <= conf[moving.content.key].max:
			typedI[item.lot] = {
				'key' : moving.content.key,
				'count' : moving.content.count + typedI[item.lot].count
			}
			typedM.erase(moving.lot)
		else:
			typedM[moving.lot] = {
				'key' : typedI[item.lot].key,
				'count' : moving.content.count + typedI[item.lot].count - conf[moving.content.key].max
			}
			typedI[item.lot] = {
				'key' : moving.content.key,
				'count' : conf[moving.content.key].max
			}
			print(typedM[moving.lot])
	else:
		if typedI.has(item.lot):
			typedM[moving.lot] = {
				'key' : typedI[item.lot].key,
				'count' : typedI[item.lot].count
			}
		else: typedM.erase(moving.lot)
		typedI[item.lot] = {
				'key' : moving.content.key,
				'count' : moving.content.count
		}
	moving = null
	print(chest)
	set_chest(chest)
	set_all()
func set_chest(storage):
	chest = storage
	for n in range(27):
		if chest.has(n):
			C_control[n].texture = load(conf[chest[n].key].icon)
			if chest[n].count > 1:
				C_labels[n].text = String(chest[n].count)
			else: C_labels[n].text = ''
		else:
			C_control[n].texture = null
			C_labels[n].text = ''
	ui.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
func set_all():
	for n in range(9):
		if all.has(n):
			control[n].texture = load(conf[all[n].key].icon)
			if all[n].count > 1:
				labels[n].text = String(all[n].count)
			else: labels[n].text = ''
		else:
			control[n].texture = null
			labels[n].text = ''
func get_lot(id, count):
	for l in range(9):
		if !all.has(l):
			return(l)
		else:
			if all[l].key == id and all[l].count + count <= conf[id].max:
				return(l)
	return(false)

func get_side(p_poz):
	var d1 = (p_poz.x + p_poz.y) / sqrt(2)
	var d2 = (p_poz.x - p_poz.y) / sqrt(2)
	var d3 = (p_poz.z + p_poz.y) / sqrt(2)
	var d4 = (p_poz.z - p_poz.y) / sqrt(2)
	var d5 = (p_poz.z + p_poz.x) / sqrt(2)
	var d6 = (p_poz.z - p_poz.x) / sqrt(2)
	if d1 >0 and d2 < 0 and d3 > 0 and d4<0:
		return(1)
	if d1 <0 and d2 < 0 and d5< 0 and d6> 0:
		return(2)
	if d1 >0 and d2 > 0 and d5 > 0 and d6<0:
		return(3)
	if d1 <0 and d2 > 0 and d3 < 0 and d4>0:
		return(6)
	if d3 <0 and d4 < 0 and d5 < 0 and d6<0:
		return(4)
	if d3 >0 and d4 > 0 and d5 > 0 and d6>0:
		return(5)


func add(key, label='', count=1, texture='', icon='', type='', loader=''):
	var lot = get_lot(key, count)
	print(lot)
	if typeof(lot) == 2:
		if all.has(lot):
			all[lot].count += count
			labels[lot].text = String(all[lot].count)
		else:
			control[lot].texture = load(conf[key].icon)
			all[lot] = {
				'key' : key,
				'count' : count,
			}
		if all[lot].count > 1:
			labels[lot].text = String(all[lot].count)
		return(true)
	return(false)
func has(key):
	return all.has(key)
func remove(key, count=1):
	if has(key):
		if count == -1:
			control[key].texture = null
			labels[key].text = ''
			all.erase(key)
		else:
			all[key].count -= count
			labels[key].text = String(all[key].count)
			if all[key].count < 1:
				control[key].texture = null
				labels[key].text = ''
				all.erase(key)
