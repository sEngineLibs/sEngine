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

	static var keyDownHandlers:Array<{key:KeyCode, callback:Void->Void}> = [];
	static var keyUpHandlers:Array<{key:KeyCode, callback:Void->Void}> = [];
	static var charPressHandlers:Array<{char:String, callback:Void->Void}> = [];
	static var hotkeyHandlers:Array<{hotkey:Array<KeyCode>, callback:Void->Void}> = [];

	static var keyHoldEventHandlers:Array<{key:KeyCode, listener:EventListener}> = [];
	static var holdHandlers:Array<(key:KeyCode) -> Void> = [];

	public static var holdInterval:Float = 0.8;

	static function set() {
		keyboard = kha.input.Keyboard.get();
		notifyOnDown(key -> {
			if (!keysPressed.contains(key)) {
				keysPressed.push(key);
				for (keyDownListener in keyDownHandlers)
					if (keyDownListener.key == key)
						keyDownListener.callback();
				for (hotkeyListener in hotkeyHandlers) {
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
				keyHoldEventHandlers.push({
					key: key,
					listener: Dispatcher.addEventListener(() -> {
						return keysPressed.contains(key) && Time.realTime >= time + holdInterval;
					}, () -> {
						for (holdListener in holdHandlers)
							holdListener(key);
					})
				});
			}
		});
		notifyOnUp(key -> {
			keysPressed.remove(key);
			for (keyUpListener in keyUpHandlers)
				if (keyUpListener.key == key)
					keyUpListener.callback();
			for (keyHoldEventListener in keyHoldEventHandlers) {
				if (keyHoldEventListener.key == key) {
					Dispatcher.removeEventListener(keyHoldEventListener.listener);
					keyHoldEventHandlers.remove(keyHoldEventListener);
				}
			}
		});
		notifyOnPressed(char -> {
			for (charPressListener in charPressHandlers)
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

	public static function notifyOnPressed(callback:String->Void) {
		keyboard.pressListeners.push(callback);
	}

	public static function removeCallbackOnPressed(callback:String->Void) {
		keyboard.pressListeners.remove(callback);
	}

	public static function notifyOnKeyDown(listener:{key:KeyCode, callback:Void->Void}) {
		keyDownHandlers.push(listener);
	}

	public static function removeCallbackOnKeyDown(listener:{key:KeyCode, callback:Void->Void}) {
		keyDownHandlers.remove(listener);
	}

	public static function notifyOnCharPressed(listener:{char:String, callback:Void->Void}) {
		charPressHandlers.push(listener);
	}

	public static function removeCallbackOnCharPressed(listener:{char:String, callback:Void->Void}) {
		charPressHandlers.remove(listener);
	}

	public static function notifyOnHotKeyPressed(listener:{hotkey:Array<KeyCode>, callback:Void->Void}) {
		hotkeyHandlers.push(listener);
	}

	public static function removeCallbackOnHotKeyPressed(listener:{hotkey:Array<KeyCode>, callback:Void->Void}) {
		hotkeyHandlers.remove(listener);
	}

	public static function notifyOnHold(callback:(key:KeyCode) -> Void) {
		holdHandlers.push(callback);
	}

	public static function removeCallbackOnHold(callback:(key:KeyCode) -> Void) {
		holdHandlers.remove(callback);
	}
}
