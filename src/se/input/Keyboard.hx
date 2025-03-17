package se.input;

typedef KeyCode = kha.input.KeyCode;

#if !macro
@:build(se.macro.SMacro.build())
#end
class Keyboard {
	var keysTimers:Map<KeyCode, Timer> = [];

	public var keysDown:Array<KeyCode> = [];
	public var holdInterval = 0.8;

	@:signal function down(key:KeyCode);

	@:signal function up(key:KeyCode);

	@:signal function hold(key:KeyCode);

	@:signal function pressed(char:String);

	@:signal(key) function keyDown(key:KeyCode);

	@:signal(key) function keyUp(key:KeyCode);

	@:signal(key) function keyHold(key:KeyCode);

	@:signal(char) function charPressed(char:String);

	var hotkeyListeners:Map<Array<KeyCode>, Array<Void->Void>> = [];

	public function new(id:Int = 0) {
		kha.input.Keyboard.get(id).notify(down.emit, up.emit, pressed.emit);

		onPressed(charPressed.emit);
		onHold(keyHold.emit);
	}

	public function onHotkeyDown(hotkey:Array<KeyCode>, slot:Void->Void) {
		for (hkl in hotkeyListeners.keys())
			if (hkl == hotkey) {
				hotkeyListeners.get(hkl).push(slot);
				return;
			}
		hotkeyListeners.set(hotkey, [slot]);
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

		keysTimers.get(key)?.stop();
		keysTimers.remove(key);
	}

	function hotkeyDown(hotkey:Array<KeyCode>) {
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
