extends Node

var _nodes_ready: Dictionary = {}
var _node_ready_callbacks: Dictionary = {}


func register_node_ready_callback(node_name: String, callback: Callable) -> void:
	if not _node_ready_callbacks.has(node_name):
		_node_ready_callbacks[node_name] = []
	_node_ready_callbacks[node_name].append(callback)


func notify_node_ready(node_name: String, node: Node = null) -> void:
	_nodes_ready[node_name] = true
	if _node_ready_callbacks.has(node_name):
		for callback in _node_ready_callbacks[node_name]:
			if callback.is_valid():
				callback.call(node_name, node)


func wait_for_node_ready(node_name: String) -> void:
	if _nodes_ready.get(node_name, false):
		return
	while not _nodes_ready.get(node_name, false):
		await get_tree().process_frame


func clear_node_ready(node_name: String) -> void:
	_nodes_ready.erase(node_name)


func reset_all() -> void:
	_nodes_ready.clear()
