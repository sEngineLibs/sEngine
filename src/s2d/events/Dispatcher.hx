package s2d.events;

@:allow(s2d.S2D)
class Dispatcher {
	static var listeners:Array<EventListener> = [];

	public static inline function add(event:Void->Bool, callback:Void->Void, ?breakable:Bool = true) {
		listeners.push(new EventListener(event, callback, breakable));
	}

	static inline function update() {
		for (listener in listeners)
			if (listener.update())
				listeners.remove(listener);
	}
}
