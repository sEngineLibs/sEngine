package se.system.input;

import kha.input.KeyCode;
import se.events.Event;
import se.events.EventListener;
import se.events.EventDispatcher;

@:allow(se.Application)
@:access(kha.input.Keyboard)
class Keyboard {
	var dispatcher:EventDispatcher = new EventDispatcher();
	var keyEvents = {
		down: new Map<KeyCode, Event>(),
		up: new Map<KeyCode, Event>(),
		pressed: new Map<KeyCode, Event>(),
		hold: new Map<KeyCode, Event>(),
	};
	var charEvents:Map<KeyCode, Event> = [];

	var timers:Map<KeyCode, Timer> = [];

	var keyboard:kha.input.Keyboard;
	var keysDown:Array<KeyCode> = [];

	public var holdInterval:Float = 0.8;

	function new(?keyboardID = 0) {
		keyboard = kha.input.Keyboard.get(keyboardID);
		keyboard.notify(down, up, press);

		dispatcher.downEvent = new Event([processDown]);
		dispatcher.upEvent = new Event([processUp]);
		dispatcher.pressEvent = new Event([processPress]);

		dispatcher.holdEvent = new Event();
	}

	public inline function isDown(key:KeyCode):Bool {
		return keysDown.contains(key);
	}

	public inline function down(key:KeyCode) {
		dispatcher.downEvent.emit(key);
	}

	public inline function up(key:KeyCode) {
		dispatcher.upEvent.emit(key);
	}

	public inline function hold(key:KeyCode) {
		dispatcher.holdEvent.emit(key);
	}

	public inline function press(char:String) {
		dispatcher.pressEvent.emit(char);
	}

	public inline function onDown(callback:(key:KeyCode) -> Void):EventListener {
		return dispatcher.downEvent.addListener(callback);
	}

	public inline function onUp(callback:(key:KeyCode) -> Void):EventListener {
		return dispatcher.upEvent.addListener(callback);
	}

	public inline function onHold(callback:(key:KeyCode) -> Void):EventListener {
		return dispatcher.holdEvent.addListener(callback);
	}

	public inline function onPressed(callback:(char:String) -> Void):EventListener {
		return dispatcher.pressEvent.addListener(callback);
	}

	public inline function onKeyDown(key:KeyCode, callback:Void->Void):EventListener {
		return dispatcher.downEvent.addListener(callback);
	}

	public inline function onKeyUp(key:KeyCode, callback:Void->Void):EventListener {
		return dispatcher.upEvent.addListener(callback);
	}

	public inline function onKeyHold(key:KeyCode, callback:Void->Void):EventListener {
		return dispatcher.holdEvent.addListener(callback);
	}

	public inline function onCharPressed(char:String, callback:Void->Void):EventListener {
		return dispatcher.pressEvent.addListener(callback);
	}

	inline function processDown(key:KeyCode) {
		if (!keysDown.contains(key))
			keysDown.push(key);
		dispatcher.emitEvent('${key}PressedEvent', key);
		timers.set(key, new Timer(() -> {
			if (isDown(key))
				hold(key);
		}, holdInterval));
		timers.get(key).start();
	}

	inline function processUp(key:KeyCode) {
		if (keysDown.contains(key))
			keysDown.remove(key);

		timers.get(key).stop();
	}

	inline function processPress(char:String) {
		dispatcher.emitEvent('${char}PressedEvent', char);
	}
}
