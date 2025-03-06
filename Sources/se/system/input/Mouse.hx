package se.system.input;

import kha.input.Mouse.MouseCursor;

#if !macro
@:build(se.macro.SMacro.build())
#end
class Mouse {
	var buttonHoldTimers:Map<MouseButton, Timer> = [];
	var recentPressed:Map<MouseButton, Timer> = [];
	var recentClicked:Map<MouseButton, Timer> = [];
	var buttonsDown:Set<MouseButton> = [];

	public var holdInterval = 0.8;
	public var clickInterval = 0.3;
	public var doubleClickInterval = 0.5;

	@:track public var x:Int = 0;
	@:track public var y:Int = 0;
	@:track public var locked:Bool = false;
	@:track public var cursor:MouseCursor = MouseCursor.Default;

	@:signal function moved(x:Int, y:Int, dx:Int, dy:Int);

	@:signal function left();

	@:signal function scrolled(delta:Int);

	@:signal function down(button:MouseButton, x:Int, y:Int);

	@:signal function up(button:MouseButton, x:Int, y:Int);

	@:signal function hold(button:MouseButton);

	@:signal function clicked(button:MouseButton);

	@:signal function doubleClicked(button:MouseButton);

	@:signal(button) function buttonDown(button:MouseButton, x:Int, y:Int);

	@:signal(button) function buttonUp(button:MouseButton, x:Int, y:Int);

	@:signal(button) function buttonHold(button:MouseButton);

	@:signal(button) function buttonClicked(button:MouseButton);

	@:signal(button) function buttonDoubleClicked(button:MouseButton);

	public function new(id:Int = 0) {
		var mouse = kha.input.Mouse.get(id);
		mouse.notify(down.emit, up.emit, moved.emit, scrolled.emit, left.emit);

		onCursorChanged(mouse.setSystemCursor);
		onLockedChanged(locked -> if (locked) mouse.lock() else mouse.unlock());

		onDoubleClicked(buttonDoubleClicked.emit);
		onHold(buttonHold.emit);

		onMoved((x, y, dx, dy) -> {
			this.x = x;
			this.y = y;
		});

		onLeft(() -> {
			recentPressed.clear();
			buttonHoldTimers.clear();
		});

		onClicked(b -> {
			buttonClicked(b);

			if (recentClicked.exists(b))
				doubleClicked(b);

			recentClicked.set(b, Timer.set(() -> recentClicked.remove(b), doubleClickInterval));
		});

		onUp((b, x, y) -> {
			buttonUp(b, x, y);

			trace(recentPressed.exists(b));
			if (recentPressed.exists(b))
				clicked(b);

			buttonHoldTimers.get(b)?.stop();
			buttonHoldTimers.remove(b);
			buttonsDown.remove(b);
		});

		onDown((b, x, y) -> {
			buttonDown(b, x, y);
			buttonsDown.push(b);

			recentPressed.set(b, Timer.set(() -> recentPressed.remove(b), clickInterval));
			buttonHoldTimers.set(b, Timer.set(() -> if (buttonHoldTimers.exists(b)) hold(b), holdInterval));
		});
	}

	public function setSystemCursor(cursor:MouseCursor) {
		this.cursor = cursor;
	}
}

typedef MouseEvent = {
	button:MouseButton,
	x:Int,
	y:Int
}

enum abstract MouseButton(Int) from Int to Int {
	var Left;
	var Right;
	var Middle;
	var Back;
	var Forward;

	@:to
	extern public inline function toString():String {
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
