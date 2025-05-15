extends ContentInfo

func _init():
	preload("res://mods/cb_inventory_use_stack/patches/MenuHelperPatch.gd").patch()
	preload("res://mods/cb_inventory_use_stack/patches/CharacterPatch.gd").patch()
	preload("res://mods/cb_inventory_use_stack/patches/CharacterLevelItemPatch.gd").patch()
