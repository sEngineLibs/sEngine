package se.events;

/**
	The Dispatcher type manages events and their listeners.
 */
extern abstract EventDispatcher(Map<String, Event>) {
	public inline function new() {
		this = [];
	}

	/**
		Gets an event from the dispatcher.

		@param eventName A name of the event.
		@return the event.
	 */
	@:op(a.b)
	public inline function getEvent(eventName:String):Event {
		return this.get(eventName);
	}

	/**
		Sets an event from the dispatcher.

		@param eventName A name of the event.
		@param event The event.
	 */
	@:op(a.b)
	public inline function setEvent(eventName:String, event:Event):Void {
		this.set(eventName, event);
	}

	/**
		Checks whether the dispatcher has an event.

		@param eventName A name of the event.
		@return `true` if the dispatcher has an event, `false` otherwise.
	 */
	public inline function hasEvent(eventName:String):Bool {
		return this.exists(eventName);
	}

	/**
		Adds an event to the dispatcher.

		@param eventName A name of the event.
		@return `true` if the event was successfully added, `false` otherwise.
	 */
	public inline function addEvent(eventName:String):Bool {
		if (hasEvent(eventName))
			return false;
		setEvent(eventName, new Event());
		return true;
	}

	/**
		Emits an event.

		@param eventName A name of the event.
		@return `true` if the event was successfully emitted, `false` otherwise.
	 */
	public inline function emitEvent(eventName:String, ?data:Dynamic):Bool {
		if (hasEvent(eventName))
			return false;
		getEvent(eventName).emit(data);
		return true;
	}

	/**
		Removes an event from the dispatcher.

		@param eventName A name of the event.
		@return `true` if the event was successfully removed, `false` otherwise.
	 */
	public inline function removeEvent(eventName:String):Bool {
		if (!hasEvent(eventName))
			return false;
		this.remove(eventName);
		return true;
	}

	/**
		Adds an event listener to the dispatcher.

		@param eventName A name of the event.
		@param listener The function to be executed.
		@return `true` if the listener was successfully added, `false` otherwise.
	 */
	public inline function addEventListener(eventName:String, listener:EventListener):Bool {
		if (!hasEvent(eventName))
			return false;
		getEvent(eventName).addListener(listener);
		return true;
	}

	/**
		Removes an event listener from the dispatcher.

		@param eventName A name of the event.
		@param listener The listener to remove.
		@return `true` if the listener was successfully removed, `false` otherwise.
	 */
	public inline function removeListener(eventName:String, listener:EventListener):Bool {
		if (!hasEvent(eventName))
			return false;
		getEvent(eventName).removeListener(listener);
		return true;
	}
}
