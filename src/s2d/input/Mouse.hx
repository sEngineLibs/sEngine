package s2d.input;

import kha.input.Mouse.MouseCursor;

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

	@:isVar public static var x(default, null):Int;
	@:isVar public static var y(default, null):Int;
	@:isVar public static var cursor(default, set):MouseCursor;

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
	}

	public static function notifyOnDown(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		mouse.windowDownListeners[windowID].push(callback);
	}

	public static function notifyOnUp(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		mouse.windowUpListeners[windowID].push(callback);
	}

	public static function notifyOnMoved(callback:(x:Int, y:Int, dx:Int, dy:Int) -> Void) {
		mouse.windowMoveListeners[windowID].push(callback);
	}

	public static function notifyOnScrolled(callback:(delta:Int) -> Void) {
		mouse.windowWheelListeners[windowID].push(callback);
	}

	public static function notifyOnLeft(callback:Void->Void) {
		mouse.windowLeaveListeners[windowID].push(callback);
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
}
