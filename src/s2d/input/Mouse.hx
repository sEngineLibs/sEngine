package s2d.input;

import kha.input.Mouse.MouseCursor;

enum abstract MouseButton(Int) from Int to Int {
	var Left;
	var Right;
	var Middle;
}

@:allow(s2d.App)
class Mouse {
	static var mouse:kha.input.Mouse;

	@:isVar public static var x(default, null):Int;
	@:isVar public static var y(default, null):Int;
	@:isVar public static var cursor(default, set):MouseCursor;

	static function set() {
		@:privateAccess mouse = kha.input.Mouse.get();
		mouse.notify((button, x, y) -> {}, (button, x, y) -> {}, (x, y, mx, my) -> {
			Mouse.x = x;
			Mouse.y = y;
		}, (delta) -> {});
	}

	public static function notifyOnDown(f:(button:MouseButton) -> Void) {
		@:privateAccess mouse.windowDownListeners[0].push((button, x, y) -> f(button));
	}

	public static function notifyOnUp(f:(button:MouseButton) -> Void) {
		@:privateAccess mouse.windowUpListeners[0].push((button, x, y) -> f(button));
	}

	public static function notifyOnMove(f:(dx:Int, dy:Int) -> Void) {
		@:privateAccess mouse.windowMoveListeners[0].push((x, y, dx, dy) -> f(dx, dy));
	}

	public static function notifyOnScroll(f:(delta:Int) -> Void) {
		@:privateAccess mouse.windowWheelListeners[0].push(f);
	}

	public static function notifyOnLeave(f:Void->Void) {
		@:privateAccess mouse.windowLeaveListeners[0].push(f);
	}

	static function set_cursor(value:MouseCursor):MouseCursor {
		cursor = value;
		mouse.setSystemCursor(value);
		return value;
	}
}
