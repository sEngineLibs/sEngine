package score;

import kha.input.Mouse;
import kha.input.Keyboard;

class Input {
	public static var mouse(get, never):Mouse;
	public static var keyboard(get, never):Keyboard;
	@:isVar public static var cursor(default, set):MouseCursor;

	static inline function get_mouse():Mouse {
		return Mouse.get();
	}

	static inline function get_keyboard():Keyboard {
		return Keyboard.get();
	}

	static inline function set_cursor(value:MouseCursor):MouseCursor {
		cursor = value;
		mouse.setSystemCursor(value);
		return value;
	}
}
