extends Node

var all = {}
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
func has(key):
	return all.has(key)
func remove(key, count=1):
	if has(key):
		if count == -1:
			control[key].texture = null
			all.erase(key)
		else:
			all[key].count -= count
			if all[key].count < 1:
				control[key].texture = null
				all.erase(key)
