package s2d.app.input;

import kha.input.Mouse.MouseCursor;
// s2d
import s2d.core.Time;
import s2d.events.Dispatcher;
import s2d.events.EventListener;

enum abstract MouseButton(Int) from Int to Int {
	var Left;
	var Right;
	var Middle;
	var Back;
	var Forward;
}

@:allow(s2d.app.App)
@:access(kha.input.Mouse)
class Mouse {
	@:isVar var windowID(default, set):Int;
	var mouse:kha.input.Mouse;

	var buttonsPressed:Array<MouseButton> = [];
	var buttonHoldEventListeners:Array<{button:MouseButton, listener:EventListener}> = [];

	var buttonHoldEventHandlers:Array<(button:MouseButton, x:Int, y:Int) -> Void> = [];
	var doubleClickHandlers:Array<(button:MouseButton, x:Int, y:Int) -> Void> = [];

	public var holdInterval:Float = 0.8;
	@:isVar public var x(default, null):Int = 0;
	@:isVar public var y(default, null):Int = 0;
	@:isVar public var cursor(default, set):MouseCursor = MouseCursor.Default;
	public var locked(get, set):Bool;

	function new(?mouseID:Int = 0, ?windowID:Int = 0) {
		mouse = kha.input.Mouse.get(mouseID);

		if (mouse.windowDownListeners == null)
			mouse.windowDownListeners = [];
		if (mouse.windowUpListeners == null)
			mouse.windowUpListeners = [];
		if (mouse.windowMoveListeners == null)
			mouse.windowMoveListeners = [];
		if (mouse.windowWheelListeners == null)
			mouse.windowWheelListeners = [];
		if (mouse.windowLeaveListeners == null)
			mouse.windowLeaveListeners = [];

		this.windowID = windowID;

		notifyOnMoved((x, y, mx, my) -> {
			this.x = x;
			this.y = y;
		});
		notifyOnDown((button, x, y) -> {
			if (!buttonsPressed.contains(button)) {
				buttonsPressed.push(button);
				var time = Time.realTime;
				buttonHoldEventListeners.push({
					button: button,
					listener: Dispatcher.addEventListener(() -> {
						return buttonsPressed.contains(button) && Time.realTime >= time + holdInterval;
					}, () -> {
						for (buttonHoldEventHandler in buttonHoldEventHandlers)
							buttonHoldEventHandler(button, x, y);
					})
				});
			}
		});
		notifyOnUp((button, x, y) -> {
			buttonsPressed.remove(button);
			for (buttonHoldEventListener in buttonHoldEventListeners) {
				if (buttonHoldEventListener.button == button) {
					Dispatcher.removeEventListener(buttonHoldEventListener.listener);
					buttonHoldEventListeners.remove(buttonHoldEventListener);
				}
			}
		});
	}

	public function notifyOnDown(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		mouse.windowDownListeners[windowID].push(callback);
		return {
			callback: callback,
			remove: () -> mouse.windowDownListeners[windowID].remove(callback)
		}
	}

	public function notifyOnUp(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		mouse.windowUpListeners[windowID].push(callback);
		return {
			callback: callback,
			remove: () -> mouse.windowUpListeners[windowID].remove(callback)
		}
	}

	public function notifyOnMoved(callback:(x:Int, y:Int, dx:Int, dy:Int) -> Void) {
		mouse.windowMoveListeners[windowID].push(callback);
		return {
			callback: callback,
			remove: () -> mouse.windowMoveListeners[windowID].remove(callback)
		}
	}

	public function notifyOnScrolled(callback:(delta:Int) -> Void) {
		mouse.windowWheelListeners[windowID].push(callback);
		return {
			callback: callback,
			remove: () -> mouse.windowWheelListeners[windowID].remove(callback)
		}
	}

	public function notifyOnLeft(callback:Void->Void) {
		mouse.windowLeaveListeners[windowID].push(callback);
		return {
			callback: callback,
			remove: () -> mouse.windowLeaveListeners[windowID].remove(callback)
		}
	}

	public function notifyOnHold(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		buttonHoldEventHandlers.push(callback);
		return {
			callback: callback,
			remove: () -> buttonHoldEventHandlers.remove(callback)
		}
	}

	public function notifyOnLockChanged(callback:Void->Void) {
		mouse.notifyOnLockChange(callback, () -> {});
		return {
			callback: callback,
			remove: () -> mouse.removeFromLockChange(callback, () -> {})
		}
	}

	function set_windowID(value:Int):Int {
		windowID = value;
		while (mouse.windowDownListeners.length <= windowID)
			mouse.windowDownListeners.push([]);
		while (mouse.windowUpListeners.length <= windowID)
			mouse.windowUpListeners.push([]);
		while (mouse.windowMoveListeners.length <= windowID)
			mouse.windowMoveListeners.push([]);
		while (mouse.windowWheelListeners.length <= windowID)
			mouse.windowWheelListeners.push([]);
		while (mouse.windowLeaveListeners.length <= windowID)
			mouse.windowLeaveListeners.push([]);
		return value;
	}

	function set_cursor(value:MouseCursor):MouseCursor {
		cursor = value;
		mouse.setSystemCursor(value);
		return value;
	}

	function get_locked():Bool {
		return mouse.isLocked();
	}

	function set_locked(value:Bool):Bool {
		if (locked != value) {
			if (locked)
				mouse.unlock();
			else
				mouse.lock();
		}
		return value;
	}
}
