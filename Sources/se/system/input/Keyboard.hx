package se.system.input;

import kha.input.KeyCode;

#if !macro
@:build(se.macro.SMacro.build())
#end
class Keyboard {
	var keysTimers:Map<KeyCode, Timer> = [];
	var hotkeyListeners:Map<Set<KeyCode>, Array<Void->Void>> = [];

	public var keysDown:Set<KeyCode> = [];
	public var holdInterval = 0.8;

	@:signal function down(key:KeyCode);

	@:signal function up(key:KeyCode);

	@:signal function hold(key:KeyCode);

	@:signal function pressed(char:String);

	@:signal(key) function keyDown(key:KeyCode);

	@:signal(key) function keyUp(key:KeyCode);

	@:signal(key) function keyHold(key:KeyCode);

	@:signal(char) function charPressed(char:String);

	public function new(id:Int = 0) {
		kha.input.Keyboard.get(id).notify(down.emit, up.emit, pressed.emit);

		onPressed(charPressed.emit);
		onHold(keyHold.emit);
	}

	@:slot(down) function _down(key:KeyCode) {
		keyDown(key);
		keysDown.push(key);

		hotkeyDown(keysDown);

		keysTimers.set(key, Timer.set(() -> {
			if (keysTimers.exists(key))
				hold(key);
		}, holdInterval));
	}

	@:slot(up) function _up(key:KeyCode) {
		keyUp(key);
		keysDown.remove(key);

		hotkeyDown(keysDown);

		keysTimers.get(key).stop();
		keysTimers.remove(key);
	}

	public function onHotkeyDown(hotkey:Set<KeyCode>, slot:Void->Void) {
		if (hotkeyListeners.exists(hotkey))
			hotkeyListeners.get(hotkey).push(slot);
		else
			hotkeyListeners.set(hotkey, [slot]);
	}

	function hotkeyDown(hotkey:Set<KeyCode>) {
		for (listener in hotkeyListeners.keyValueIterator())
			if (listener.key.length == hotkey.length) {
				var flag = true;
				for (k in listener.key)
					if (!hotkey.contains(k)) {
						flag = false;
						break;
					}
				if (flag) {
					for (callback in listener.value)
						callback();
					break;
				}
			}
	}
}
