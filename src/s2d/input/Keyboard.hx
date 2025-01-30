package s2d.input;

import kha.input.KeyCode;

@:allow(s2d.App)
@:access(kha.input.Keyboard)
class Keyboard {
	static var keyboard:kha.input.Keyboard;
	static var keysPressed:Array<KeyCode> = [];

	static var hotkeyListeners:Array<{hotkey:Array<KeyCode>, callback:Void->Void}> = [];

	static function set() {
		keyboard = kha.input.Keyboard.get();
		notifyOnDown(button -> {
			if (!keysPressed.contains(button)) {
				keysPressed.push(button);
				processHotkeys();
			}
		});
		notifyOnUp(button -> keysPressed.remove(button));
	}

	static function processHotkeys() {
		for (hotkeyListener in hotkeyListeners) {
			var flag = true;
			for (key in hotkeyListener.hotkey)
				if (!keysPressed.contains(key)) {
					flag = false;
					break;
				}
			if (flag)
				hotkeyListener.callback();
		}
	}

	public static function notifyOnDown(listener:KeyCode->Void) {
		keyboard.downListeners.push(listener);
	}

	public static function removeDownListener(listener:KeyCode->Void) {
		keyboard.downListeners.remove(listener);
	}

	public static function notifyOnUp(listener:KeyCode->Void) {
		keyboard.upListeners.push(listener);
	}

	public static function removeUpListener(listener:KeyCode->Void) {
		keyboard.upListeners.remove(listener);
	}

	public static function notifyOnPressed(listener:String->Void) {
		keyboard.pressListeners.push(listener);
	}

	public static function removePressListener(listener:String->Void) {
		keyboard.pressListeners.remove(listener);
	}

	public static function notifyOnHotKeyPressed(listener:{hotkey:Array<KeyCode>, callback:Void->Void}) {
		hotkeyListeners.push(listener);
	}

	public static function removeHotKeyListener(listener:{hotkey:Array<KeyCode>, callback:Void->Void}) {
		hotkeyListeners.remove(listener);
	}
}
