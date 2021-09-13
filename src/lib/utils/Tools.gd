extends Reference
class_name Tools


static func resolve_connection(from: Object, with_signal: String, to: Object, target_method: String,
		args: Array = []) -> void:
	
	if (from.connect(with_signal, to, target_method, args)):
		push_warning("Woldn't able to connect signal %s from %s to %s" % [with_signal, from, to])


#static func property_interpolation(tween: Tween, target: Object, property: NodePath, from, to, )

#static func batch_connections() -> void:
