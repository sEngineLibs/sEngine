package s2d.input;

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

@:allow(s2d.App)
@:access(kha.input.Mouse)
class Mouse {
	@:isVar static var windowID(default, set):Int;
	static var mouse:kha.input.Mouse;

	static var buttonsPressed:Array<MouseButton> = [];
	static var buttonHoldEventListeners:Array<{button:MouseButton, listener:EventListener}> = [];

	static var buttonHoldEventHandlers:Array<(button:MouseButton, x:Int, y:Int) -> Void> = [];
	static var doubleClickHandlers:Array<(button:MouseButton, x:Int, y:Int) -> Void> = [];

	public static var holdInterval:Float = 0.8;
	@:isVar public static var x(default, null):Int = 0;
	@:isVar public static var y(default, null):Int = 0;
	@:isVar public static var cursor(default, set):MouseCursor = MouseCursor.Default;
	@:isVar public static var locked(default, set):Bool = false;

	static function set(?mouseID:Int = 0, ?windowID:Int = 0) {
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

		Mouse.windowID = windowID;

		notifyOnMoved((x, y, mx, my) -> {
			Mouse.x = x;
			Mouse.y = y;
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

	public static function notifyOnDown(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		mouse.windowDownListeners[windowID].push(callback);
	}

	public static function removeCallbackOnDown(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		mouse.windowDownListeners[windowID].remove(callback);
	}

	public static function notifyOnUp(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		mouse.windowUpListeners[windowID].push(callback);
	}

	public static function removeCallbackOnUp(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		mouse.windowUpListeners[windowID].remove(callback);
	}

	public static function notifyOnMoved(callback:(x:Int, y:Int, dx:Int, dy:Int) -> Void) {
		mouse.windowMoveListeners[windowID].push(callback);
	}

	public static function removeCallbackOnMoved(callback:(x:Int, y:Int, dx:Int, dy:Int) -> Void) {
		mouse.windowMoveListeners[windowID].remove(callback);
	}

	public static function notifyOnScrolled(callback:(delta:Int) -> Void) {
		mouse.windowWheelListeners[windowID].push(callback);
	}

	public static function removeCallbackOnScrolled(callback:(delta:Int) -> Void) {
		mouse.windowWheelListeners[windowID].remove(callback);
	}

	public static function notifyOnLeft(callback:Void->Void) {
		mouse.windowLeaveListeners[windowID].push(callback);
	}

	public static function removeCallbackOnLeft(callback:Void->Void) {
		mouse.windowLeaveListeners[windowID].remove(callback);
	}

	public static function notifyOnHold(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		buttonHoldEventHandlers.push(callback);
	}

	public static function removeCallbackOnHold(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		buttonHoldEventHandlers.remove(callback);
	}

	public static function notifyOnLockChanged(callback:Void->Void) {
		mouse.notifyOnLockChange(callback, () -> {});
	}

	public static function removeCallbackOnLockChanged(callback:Void->Void) {
		mouse.removeFromLockChange(callback, () -> {});
	}

	static function set_windowID(value:Int):Int {
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

	static function set_cursor(value:MouseCursor):MouseCursor {
		cursor = value;
		mouse.setSystemCursor(value);
		return value;
	}

	static function set_locked(value:Bool):Bool {
		if (locked != value) {
			locked = value;
			if (locked)
				mouse.lock();
			else
				mouse.unlock();
		}
		return value;
	}
}
