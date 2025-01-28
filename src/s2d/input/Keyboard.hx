package s2d.input;

import kha.input.KeyCode;

@:allow(s2d.App)
class Keyboard {
	static var keyboard:kha.input.Keyboard;

	static function set() {
		@:privateAccess keyboard = kha.input.Keyboard.get();
	}

	public static function notifyOnDown(f:(button:KeyCode) -> Void) {
		@:privateAccess keyboard.downListeners.push((button) -> f(button));
	}

	public static function notifyOnUp(f:(button:KeyCode) -> Void) {
		@:privateAccess keyboard.upListeners.push((button) -> f(button));
	}

	public static function notifyOnPressed(f:(button:KeyCode) -> Void) {
		@:privateAccess keyboard.downListeners.push((button) -> f(button));
	}
}
