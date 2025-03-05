package se.system.input;

import kha.input.Mouse.MouseCursor;

#if !macro
@:build(se.macro.SMacro.build())
#end
class Mouse {
	var buttonsTimers:Map<MouseButton, Timer> = [];
	var recentPressed:Map<MouseButton, Timer> = [];

	var buttonDownSlots:Map<MouseButton, Array<(x:Int, y:Int) -> Void>> = [];
	var buttonUpSlots:Map<MouseButton, Array<(x:Int, y:Int) -> Void>> = [];
	var buttonHoldSlots:Map<MouseButton, Array<Void->Void>> = [];

	public var holdInterval = 0.8;
	public var doubleClickInterval = 0.5;

	/**
	 * If set to `true`, locks the cursor position and hides it. For catching movements, use the `dx`/`dy` arguments of your `onMoved` handler.
	 * @param a bbbb
	 */
	@:track public var locked:Bool = false;

	@:track public var x:Int = 0;
	@:track public var y:Int = 0;
	@:track public var cursor:MouseCursor = MouseCursor.Default;
	@:track public var buttonsDown:Array<MouseButton> = [];

	public function new(id:Int = 0) {
		var mouse = kha.input.Mouse.get(id);
		mouse.notify(down.emit, up.emit, moved.emit, scrolled.emit);
		onDown(processDown);
		onUp(processUp);
		onMoved(processMoved);
		onHold(processHold);
		onCursorChanged(mouse.setSystemCursor);
		onLockedChanged(locked -> if (locked) mouse.lock() else mouse.unlock());
	}

	public function setSystemCursor(cursor:MouseCursor) {
		this.cursor = cursor;
	}

	public function onButtonDown(button:MouseButton, slot:(x:Int, y:Int) -> Void) {
		if (buttonDownSlots.exists(button))
			buttonDownSlots.get(button).push(slot);
		else
			buttonDownSlots.set(button, [slot]);
	}

	public function onButtonUp(button:MouseButton, slot:(x:Int, y:Int) -> Void) {
		if (buttonUpSlots.exists(button))
			buttonUpSlots.get(button).push(slot);
		else
			buttonUpSlots.set(button, [slot]);
	}

	public function onButtonHold(button:MouseButton, slot:Void->Void) {
		if (buttonHoldSlots.exists(button))
			buttonHoldSlots.get(button).push(slot);
		else
			buttonHoldSlots.set(button, [slot]);
	}

	inline function processDown(button:MouseButton, x:Int, y:Int) {
		var t = new Timer(() -> {
			if (buttonsTimers.exists(button))
				hold(button);
		}, holdInterval);
		t.start();
		buttonsTimers.set(button, t);

		buttonsDown = [for (key in buttonsTimers.keys()) key];
		buttonDown(button, x, y);

		if (recentPressed.exists(button))
			doubleClicked(button, x, y);

		var d = new Timer(() -> {
			recentPressed.remove(button);
		}, doubleClickInterval);
		d.start();
		recentPressed.set(button, d);
	}

	inline function processUp(button:MouseButton, x:Int, y:Int) {
		buttonsTimers.get(button).stop();
		buttonsTimers.remove(button);

		buttonUp(button, x, y);
	}

	inline function processMoved(x:Int, y:Int, dx:Int, dy:Int) {
		this.x = x;
		this.y = y;
	}

	inline function processHold(button:MouseButton) {
		buttonHold(button);
	}

	@:signal function down(button:MouseButton, x:Int, y:Int);

	@:signal function up(button:MouseButton, x:Int, y:Int);

	@:signal function doubleClicked(button:MouseButton, x:Int, y:Int);

	@:signal function hold(button:MouseButton);

	@:signal function moved(x:Int, y:Int, dx:Int, dy:Int);

	@:signal function scrolled(delta:Int);

	function buttonDown(button:MouseButton, x:Int, y:Int) {
		for (slot in buttonDownSlots.get(button))
			slot(x, y);
	}

	function buttonUp(button:MouseButton, x:Int, y:Int) {
		for (slot in buttonUpSlots.get(button))
			slot(x, y);
	}

	function buttonHold(button:MouseButton) {
		for (slot in buttonHoldSlots.get(button))
			slot();
	}
}

enum abstract MouseButton(Int) from Int to Int {
	var Left;
	var Right;
	var Middle;
	var Back;
	var Forward;
}
