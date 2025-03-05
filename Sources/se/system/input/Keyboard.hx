package se.system.input;

import kha.input.KeyCode;

#if !macro
@:build(se.macro.SMacro.build())
#end
class Keyboard {
	var keysTimers:Map<KeyCode, Timer> = [];
	var hotkeyListeners:Map<Array<KeyCode>, Array<Void->Void>> = [];

	var keyDownSlots:Map<KeyCode, Array<Void->Void>> = [];
	var keyUpSlots:Map<KeyCode, Array<Void->Void>> = [];
	var keyHoldSlots:Map<KeyCode, Array<Void->Void>> = [];
	var charPressedSlots:Map<String, Array<Void->Void>> = [];

	public var holdInterval = 0.8;

	@:track public var keysDown:Array<kha.input.KeyCode> = [];

	public function new(id:Int = 0) {
		kha.input.Keyboard.get(id).notify(down.emit, up.emit, pressed.emit);

		onDown(processDown);
		onUp(processUp);
		onPressed(processPressed);
		onHold(processHold);
	}

	public function onHotkeyDown(hotkey:Array<KeyCode>, slot:Void->Void) {
		if (hotkeyListeners.exists(hotkey))
			hotkeyListeners.get(hotkey).push(slot);
		else
			hotkeyListeners.set(hotkey, [slot]);
	}

	public function onKeyDown(key:KeyCode, slot:Void->Void) {
		if (keyDownSlots.exists(key))
			keyDownSlots.get(key).push(slot);
		else
			keyDownSlots.set(key, [slot]);
	}

	public function onKeyUp(key:KeyCode, slot:Void->Void) {
		if (keyUpSlots.exists(key))
			keyUpSlots.get(key).push(slot);
		else
			keyUpSlots.set(key, [slot]);
	}

	public function onKeyHold(key:KeyCode, slot:Void->Void) {
		if (keyHoldSlots.exists(key))
			keyHoldSlots.get(key).push(slot);
		else
			keyHoldSlots.set(key, [slot]);
	}

	public function onCharPressed(char:String, slot:Void->Void) {
		if (charPressedSlots.exists(char))
			charPressedSlots.get(char).push(slot);
		else
			charPressedSlots.set(char, [slot]);
	}

	inline function processDown(key:KeyCode) {
		var t = new Timer(() -> {
			if (keysTimers.exists(key))
				hold(key);
		}, holdInterval);
		t.start();
		keysTimers.set(key, t);
		keysDown = [for (key in keysTimers.keys()) key];

		keyDown(key);
		hotkeyDown(keysDown);
	}

	inline function processUp(key:KeyCode) {
		keysTimers.get(key).stop();
		keysTimers.remove(key);
		keysDown = [for (key in keysTimers.keys()) key];

		keyUp(key);
		hotkeyDown(keysDown);
	}

	inline function processHold(key:KeyCode) {
		keyHold(key);
	}

	inline function processPressed(char:String) {
		charPressed(char);
	}

	@:signal function down(key:kha.input.KeyCode);

	@:signal function up(key:kha.input.KeyCode);

	@:signal function hold(key:kha.input.KeyCode);

	@:signal function pressed(char:String);

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

	function keyDown(key:KeyCode) {
		for (slot in keyDownSlots.get(key))
			slot();
	}

	function keyUp(key:KeyCode) {
		for (slot in keyUpSlots.get(key))
			slot();
	}

	function keyHold(key:KeyCode) {
		for (slot in keyHoldSlots.get(key))
			slot();
	}

	function charPressed(char:String) {
		for (slot in charPressedSlots.get(char))
			slot();
	}
}
