package se.events;

/**
	The Dispatcher class manages event listeners and their execution.

	It allows adding and removing event listeners, and updates them every frame.

	@see `EventListener`
 */
@:allow(se.system.App)
class Dispatcher {
	static var listeners:Array<EventListener> = [];

	/**
		Adds an event listener to the dispatcher.

		@param event A function that returns `true` when the event condition is met.
		@param callback The function to be executed when the event triggers.
		@param breakable If `true`, the event listener will be removed after execution.
		@return The created `EventListener` instance.
	 */
	public static function addEventListener(event:Void->Bool, callback:Void->Void, ?breakable:Bool = true):EventListener {
		final listener = new EventListener(event, callback, breakable);
		listeners.push(listener);
		return listener;
	}

	/**
		Removes an event listener from the dispatcher.

		@param listener The `EventListener` instance to remove.
		@return `true` if the listener was successfully removed, `false` otherwise.
	 */
	public static function removeEventListener(listener:EventListener):Bool {
		return listeners.remove(listener);
	}

	static function update() {
		for (listener in listeners)
			if (listener.update())
				listeners.remove(listener);
	}
}
