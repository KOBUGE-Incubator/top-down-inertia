
extends Node

signal amount_changed(resource)

var resources = {}
var new_resources = {}

func get_resource_amount(name):
	var return_value = 0
	
	if resources.has(name):
		return_value += resources[name]
	
	if new_resources.has(name):
		return_value +=  new_resources[name]
	
	return return_value

func set_resource_amount(name, amount, pernament = false):
	if pernament:
		resources[name] = amount
	else:
		if resources.has(name):
			new_resources[name] = amount - resources[name]
		else:
			new_resources[name] = amount
	emit_signal("amount_changed", name)

func add_resource_amount(name, amount, pernament = false):
	if pernament:
		if resources.has(name):
			resources[name] += amount
		else:
			resources[name] = amount
	else:
		if new_resources.has(name):
			new_resources[name] += amount
		else:
			new_resources[name] = amount
	emit_signal("amount_changed", name)

func fix_amounts(name = null):
	if name == null:
		for name in resources:
			resources[name] = get_resource_amount(name)
			if !new_resources.has(name):
				emit_signal("amount_changed", name)
		for name in new_resources:
			if !resources.has(name):
				resources[name] = get_resource_amount(name)
	else:
		resources[name] = get_resource_amount(name)
	restart_amounts(name)

func restart_amounts(name = null):
	if name == null:
		new_resources = {}
		for name in new_resources:
			emit_signal("amount_changed", name)
	else:
		new_resources[name] = 0
		emit_signal("amount_changed", name)