package s2d.app.input;

import kha.input.KeyCode;
// s2d
import s2d.core.Time;
import s2d.events.Dispatcher;
import s2d.events.EventListener;

@:allow(s2d.app.App)
@:access(kha.input.Keyboard)
class Keyboard {
	var keyboard:kha.input.Keyboard;
	var keysPressed:Array<KeyCode> = [];

	var keyDownHandlers:Array<{key:KeyCode, callback:Void->Void}> = [];
	var keyUpHandlers:Array<{key:KeyCode, callback:Void->Void}> = [];
	var charPressHandlers:Array<{char:String, callback:Void->Void}> = [];
	var hotkeyHandlers:Array<{hotkey:Array<KeyCode>, callback:Void->Void}> = [];

	var keyHoldEventHandlers:Array<{key:KeyCode, listener:EventListener}> = [];
	var holdHandlers:Array<(key:KeyCode) -> Void> = [];

	public var holdInterval:Float = 0.8;

	function new(?keyboardID = 0) {
		keyboard = kha.input.Keyboard.get(keyboardID);
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

	public function notifyOnDown(callback:KeyCode->Void) {
		keyboard.downListeners.push(callback);
		return {
			callback: callback,
			remove: () -> keyboard.downListeners.remove(callback)
		}
	}

	public function notifyOnUp(callback:KeyCode->Void) {
		keyboard.upListeners.push(callback);
		return {
			callback: callback,
			remove: () -> keyboard.upListeners.remove(callback)
		}
	}

	public function notifyOnPressed(callback:String->Void) {
		keyboard.pressListeners.push(callback);
		return {
			callback: callback,
			remove: () -> keyboard.pressListeners.remove(callback)
		}
	}

	public function notifyOnHold(callback:(key:KeyCode) -> Void) {
		holdHandlers.push(callback);
		return {
			callback: callback,
			remove: () -> holdHandlers.remove(callback)
		}
	}

	public function notifyOnKeyDown(key:KeyCode, callback:Void->Void) {
		var handler = {
			key: key,
			callback: callback,
			remove: null
		};
		keyDownHandlers.push(handler);
		handler.remove = () -> keyDownHandlers.remove(handler);
		return handler;
	}

	public function notifyOnCharPressed(char:String, callback:Void->Void) {
		var handler = {
			char: char,
			callback: callback,
			remove: null
		};
		charPressHandlers.push(handler);
		handler.remove = () -> charPressHandlers.remove(handler);
		return handler;
	}

	public function notifyOnHotKeyPressed(hotkey:Array<KeyCode>, callback:Void->Void) {
		var handler = {
			hotkey: hotkey,
			callback: callback,
			remove: null
		};
		hotkeyHandlers.push(handler);
		handler.remove = () -> hotkeyHandlers.remove(handler);
		return handler;
	}
}
