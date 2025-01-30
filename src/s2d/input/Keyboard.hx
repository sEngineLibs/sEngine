package s2d.input;

import kha.input.KeyCode;
// s2d
import s2d.core.Time;
import s2d.events.Dispatcher;
import s2d.events.EventListener;

@:allow(s2d.App)
@:access(kha.input.Keyboard)
class Keyboard {
	static var keyboard:kha.input.Keyboard;
	static var keysPressed:Array<KeyCode> = [];

	static var keyDownListeners:Array<{key:KeyCode, callback:Void->Void}> = [];
	static var keyUpListeners:Array<{key:KeyCode, callback:Void->Void}> = [];
	static var charPressListeners:Array<{char:String, callback:Void->Void}> = [];
	static var hotkeyListeners:Array<{hotkey:Array<KeyCode>, callback:Void->Void}> = [];

	static var keyHoldEventListeners:Array<{key:KeyCode, listener:EventListener}> = [];
	static var holdListeners:Array<(key:KeyCode) -> Void> = [];

	public static var holdInterval:Float = 0.8;

	static function set() {
		keyboard = kha.input.Keyboard.get();
		notifyOnDown(key -> {
			if (!keysPressed.contains(key)) {
				keysPressed.push(key);
				for (keyDownListener in keyDownListeners)
					if (keyDownListener.key == key)
						keyDownListener.callback();
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
				var time = Time.realTime;
				keyHoldEventListeners.push({
					key: key,
					listener: Dispatcher.addEventListener(() -> {
						return keysPressed.contains(key) && Time.realTime >= time + holdInterval;
					}, () -> {
						for (holdListener in holdListeners)
							holdListener(key);
					})
				});
			}
		});
		notifyOnUp(key -> {
			keysPressed.remove(key);
			for (keyUpListener in keyUpListeners)
				if (keyUpListener.key == key)
					keyUpListener.callback();
			for (keyHoldEventListener in keyHoldEventListeners) {
				if (keyHoldEventListener.key == key) {
					Dispatcher.removeEventListener(keyHoldEventListener.listener);
					keyHoldEventListeners.remove(keyHoldEventListener);
				}
			}
		});
		notifyOnPress(char -> {
			for (charPressListener in charPressListeners)
				if (charPressListener.char == char)
					charPressListener.callback();
		});
	}

	public static function notifyOnDown(callback:KeyCode->Void) {
		keyboard.downListeners.push(callback);
	}

	public static function removeCallbackOnDown(callback:KeyCode->Void) {
		keyboard.downListeners.remove(callback);
	}

	public static function notifyOnUp(callback:KeyCode->Void) {
		keyboard.upListeners.push(callback);
	}

	public static function removeCallbackOnUp(callback:KeyCode->Void) {
		keyboard.upListeners.remove(callback);
	}

	public static function notifyOnPress(callback:String->Void) {
		keyboard.pressListeners.push(callback);
	}

	public static function removeCallbackOnPress(callback:String->Void) {
		keyboard.pressListeners.remove(callback);
	}

	public static function notifyOnKeyDown(listener:{key:KeyCode, callback:Void->Void}) {
		keyDownListeners.push(listener);
	}

	public static function removeCallbackOnKeyDown(listener:{key:KeyCode, callback:Void->Void}) {
		keyDownListeners.remove(listener);
	}

	public static function notifyOnCharPress(listener:{char:String, callback:Void->Void}) {
		charPressListeners.push(listener);
	}

	public static function removeCallbackOnCharPress(listener:{char:String, callback:Void->Void}) {
		charPressListeners.remove(listener);
	}

	public static function notifyOnHotKey(listener:{hotkey:Array<KeyCode>, callback:Void->Void}) {
		hotkeyListeners.push(listener);
	}

	public static function removeCallbackOnHotKey(listener:{hotkey:Array<KeyCode>, callback:Void->Void}) {
		hotkeyListeners.remove(listener);
	}

	public static function notifyOnHold(callback:(key:KeyCode) -> Void) {
		holdListeners.push(callback);
	}

	public static function removeCallbackOnHold(callback:(key:KeyCode) -> Void) {
		holdListeners.remove(callback);
	}
}
