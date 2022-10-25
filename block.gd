extends KinematicBody

export var key = 0
export var label = ""
export var count = 1
export(Texture) var texture
export(Texture) var icon

func action():
	print("Action", key)
#	G.global.add(key, label, count, texture, icon)
	G.add(key, label, count, texture, icon)
	print(G.all)
