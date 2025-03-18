package se.input;

import kha.input.Mouse.MouseCursor;

#if !macro
@:build(se.macro.SMacro.build())
#end
class Mouse {
	var buttonHoldTimers:Map<MouseButton, Timer> = [];
	var recentPressed:Map<MouseButton, Timer> = [];
	var recentClicked:Map<MouseButton, Timer> = [];
	var buttonsDown:Array<MouseButton> = [];

	public var holdInterval = 0.8;
	public var clickInterval = 0.3;
	public var doubleClickInterval = 0.5;

	@track public var x:Int = 0;
	@track public var y:Int = 0;
	@track public var locked:Bool = false;
	@track public var cursor:MouseCursor = MouseCursor.Default;

	@:signal function left();

	@:signal function scrolled(delta:Int);

	@:signal function moved(x:Int, y:Int, dx:Int, dy:Int);

	@:signal function down(button:MouseButton, x:Int, y:Int);

	@:signal function up(button:MouseButton, x:Int, y:Int);

	@:signal function hold(button:MouseButton, x:Int, y:Int);

	@:signal function clicked(button:MouseButton, x:Int, y:Int);

	@:signal function doubleClicked(button:MouseButton, x:Int, y:Int);

	@:signal(button) function buttonDown(button:MouseButton, x:Int, y:Int);

	@:signal(button) function buttonUp(button:MouseButton, x:Int, y:Int);

	@:signal(button) function buttonHold(button:MouseButton, x:Int, y:Int);

	@:signal(button) function buttonClicked(button:MouseButton, x:Int, y:Int);

	@:signal(button) function buttonDoubleClicked(button:MouseButton, x:Int, y:Int);

	public function new(id:Int = 0) {
		var mouse = kha.input.Mouse.get(id);
		mouse.notify(down.emit, up.emit, moved.emit, scrolled.emit, left.emit);

		onCursorChanged(mouse.setSystemCursor);
		onLockedChanged(locked -> if (locked) mouse.lock() else mouse.unlock());

		onDoubleClicked(buttonDoubleClicked.emit);
		onHold(buttonHold.emit);
	}

	public function setSystemCursor(cursor:MouseCursor) {
		this.cursor = cursor;
	}

	@:slot(down) function _down(button:MouseButton, x:Int, y:Int) {
		buttonDown(button, x, y);
		buttonsDown.push(button);

		recentPressed.set(button, Timer.set(() -> {
			recentPressed.remove(button);
		}, clickInterval));
		buttonHoldTimers.set(button, Timer.set(() -> {
			if (buttonHoldTimers.exists(button))
				hold(button, this.x, this.y);
		}, holdInterval));
	}

	@:slot(up) function _up(button:MouseButton, x:Int, y:Int) {
		buttonUp(button, x, y);

		if (recentPressed.exists(button))
			clicked(button, x, y);

		buttonHoldTimers.get(button)?.stop();
		buttonHoldTimers.remove(button);
		buttonsDown.remove(button);
	}

	@:slot(clicked) function _clicked(button:MouseButton, x:Int, y:Int) {
		buttonClicked(button, x, y);

		if (recentClicked.exists(button))
			doubleClicked(button, x, y);

		recentClicked.set(button, Timer.set(() -> recentClicked.remove(button), doubleClickInterval));
	}

	@:slot(left) function _left() {
		recentPressed.clear();
		buttonHoldTimers.clear();
	}

	@:slot(moved) function _moved(x:Int, y:Int, dx:Int, dy:Int) {
		this.x = x;
		this.y = y;
	}
}

enum abstract MouseButton(Int) from Int to Int {
	var Left;
	var Right;
	var Middle;
	var Back;
	var Forward;

	@:to
	public function toString():String {
		final map = [
			Left => "Left",
			Right => "Right",
			Middle => "Middle",
			Back => "Back",
			Forward => "Forward"
		];
		return 'MouseButton.${map.get(this)}';
	}
}
