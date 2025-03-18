package se.events;

@:forward.new
@:forward(callback, breakable)
extern abstract EventListener(EventListenerData) from EventListenerData to EventListenerData {
	@:from
	overload public static inline function fromCallback(callback:Dynamic->Void) {
		return new EventListener(callback);
	}

	@:from
	overload public static inline function fromCallback(callback:Void->Void) {
		return new EventListener((v) -> callback());
	}

	public var event(get, never):Event;

	@:op(a())
	public inline function call(?data:Dynamic) {
		this.callback(data);
		if (this.breakable)
			remove();
	}

	public inline function remove() {
		@:privateAccess this.event?.removeListener(this);
	}

	private inline function get_event():Event {
		@:privateAccess return this.event;
	}
}

class EventListenerData {
	var event:Event;

	public var breakable:Bool;
	public var callback:Dynamic<Void>->Void;

	public inline function new(callback:Dynamic<Void>->Void, breakable = false) {
		this.callback = callback;
		this.breakable = breakable;
	}
}
