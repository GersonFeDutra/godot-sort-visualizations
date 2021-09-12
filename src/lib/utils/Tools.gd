extends Reference
class_name Tools


static func resolve_connection(from: Node, with_signal: String, to: Node, target_method: String,
		args: Array = []) -> void:
	
	if (from.connect(with_signal, to, target_method, args)):
		push_warning("Woldn't able to connect signal %s from %s to %s" % [with_signal, from, to])


#static func batch_connections() -> void:
