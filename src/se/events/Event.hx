package se.events;

extern abstract Event(Array<EventListener>) from Array<EventListener> {
	public inline function new(?listeners:Array<EventListener>) {
		this = listeners ?? [];
	}

	/**
		Adds a listener to the event.

		@param listener The function to be executed.
	 */
	public inline function addListener(listener:EventListener):EventListener @:privateAccess {
		this.push(listener);
		(listener : se.events.EventListener.__EventListener__).event = this;
		return listener;
	}

	/**
		Removes a listener from the event.

		@param listener The listener to remove.
	 */
	public inline function removeListener(listener:EventListener):Void {
		this.remove(listener);
	}

	/**
		Emits an event.
	 */
	@:op(a())
	public inline function emit(?data:Dynamic):Void {
		for (listener in this)
			listener(data);
	}
}
