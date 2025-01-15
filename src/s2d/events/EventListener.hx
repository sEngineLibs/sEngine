package s2d.events;

@:allow(s2d.events.Dispatcher)
class EventListener {
	var event:Void->Bool;
	var callback:Void->Void;
	var breakable:Bool;

	public inline function new(event:Void->Bool, callback:Void->Void, breakable:Bool) {
		this.event = event;
		this.callback = callback;
		this.breakable = breakable;
	}

	inline function update():Bool {
		if (event()) {
			callback();
			return breakable;
		}
		return false;
	}
}
