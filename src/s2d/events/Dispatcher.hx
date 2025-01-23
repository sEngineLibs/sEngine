package s2d.events;

@:allow(s2d.S2D)
class Dispatcher {
	static var listeners:Array<EventListener> = [];

	public static function addEventListener(event:Void->Bool, callback:Void->Void, ?breakable:Bool = true):EventListener {
		final listener = new EventListener(event, callback, breakable);
		listeners.push(listener);
		return listener;
	}

	static function update() {
		for (listener in listeners)
			if (listener.update())
				listeners.remove(listener);
	}
}
