package se.events;

/**
	Represents an event listener that waits for a condition to be met and then executes a callback.

	This class is used internally by the `Dispatcher` to manage event-based logic.

	@see `Dispatcher`
 */
@:allow(se.events.Dispatcher)
@:access(se.events.Dispatcher)
class EventListener {
	var event:Void->Bool;
	var callback:Void->Void;
	var breakable:Bool;

	function new(event:Void->Bool, callback:Void->Void, breakable:Bool) {
		this.event = event;
		this.callback = callback;
		this.breakable = breakable;
	}

	function update():Bool {
		if (event()) {
			callback();
			return breakable;
		}
		return false;
	}

	/**
		Stops the listener and removes it from the `Dispatcher`.
	 */
	public function stop() {
		Dispatcher.listeners.remove(this);
	}
}
