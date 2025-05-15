extends "res://menus/BaseMenu.gd"

export (int) var min_value: int = 1
export (int) var max_value: int = 100
export (int) var step: int = 1
export (int) var value: int = 0 setget set_value

onready var num_label = find_node("NumLabel")
onready var mode_label = find_node("ModeLabel")
onready var item_label = find_node("ItemLabel")
onready var icon_texture = find_node("IconTexture")

var item: BaseItem setget set_item

func _ready():
	refresh()

func set_value(x: int):
	value = int(clamp(x, min_value, max_value))
	value = (value / step) * step
	refresh()

func set_item(value: BaseItem):
	item = value
	refresh()

func refresh():
	if not num_label:
		return
	
	num_label.text = str(value)
	mode_label.text = "ITEM_USE"
	
	if item == null:
		item_label.text = ""
		icon_texture.texture = null
	else:
		item_label.text = Loc.tr(item.name)
		icon_texture.texture = item.icon

func _step_value(amount: int):
	var x: int = value
	x += amount
	if x < min_value:
		x = max_value
	elif x > max_value:
		x = min_value
	x = (x / step) * step
	set_value(x)

func _gui_input(event: InputEvent):
	if event.is_action_pressed("ui_up"):
		_step_value(step)
		accept_event()
	elif event.is_action_pressed("ui_down"):
		_step_value( - step)
		accept_event()
	elif event.is_action_pressed("ui_left"):
		_step_value( - 10)
		accept_event()
	elif event.is_action_pressed("ui_right"):
		_step_value(10)
		accept_event()
	elif event.is_action_pressed("ui_accept"):
		accept_event()
		choose_option(value)
	elif event.is_action_pressed("ui_cancel"):
		accept_event()
		cancel()

func _on_UpButton_pressed():
	_step_value(step)

func _on_DownButton_pressed():
	_step_value( - step)

func _on_AcceptButton_pressed():
	choose_option(value)
