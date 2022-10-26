extends Node

var all = {}
var conf = {0: {'label': 'dirt', 'count': 1, 'texture': "res://dirt.png", 'icon': "res://dirt_icon.png"}, 1: {'label': 'rock', 'count': 1, 'texture': "res://rock.png", 'icon': "res://rock_icon.png"}}
var control
var labels

func add(key, label='', count=1, texture='', icon=''):
	if all.has(key):
		all[key].count += count
		labels[key].text = String(all[key].count)
	else:
		control[key].texture = load(icon)
		all[key] = {
			'label' : label,
			'count' : count,
			'texture' : texture,
			'icon' : icon
		}
	if all[key].count > 1:
		labels[key].text = String(all[key].count)
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
