package s2d.ui.elements;

import s2d.input.Mouse.MouseButton;

class MouseArea extends UIElement {
	@:isVar public var entered(default, set):Bool = false;
	@:isVar public var pressed(default, set):Bool = false;

	public var acceptedButtons:Array<MouseButton> = [MouseButton.Left];

	var enterListeners:Array<Void->Void> = [];
	var exitListeners:Array<Void->Void> = [];
	var pressListeners:Array<Void->Void> = [];
	var releaseListeners:Array<Void->Void> = [];
	var clickListeners:Array<Void->Void> = [];

	public function new(?scene:UIScene) {
		super(scene);
		App.input.mouse.notifyOnMoved((mx, my, dx, dy) -> {
			final p = finalModel.inverse().multvec({x: mx, y: my});
			final _x = p.x - x;
			final _y = p.y - y;
			if (0.0 <= _x && _x <= width && 0.0 <= _y && _y <= height)
				entered = true;
			else
				entered = false;
		});

		App.input.mouse.notifyOnDown((button, x, y) -> {
			if (acceptedButtons.contains(button))
				if (entered)
					press();
		});

		App.input.mouse.notifyOnUp((button, x, y) -> {
			if (acceptedButtons.contains(button)) {
				release();
				if (entered)
					click();
			}
		});
	}

	public function press() {
		pressed = true;
	}

	public function release() {
		pressed = false;
	}

	public function click() {
		for (callback in clickListeners)
			callback();
	}

	public function notifyOnEntered(callback:Void->Void) {
		enterListeners.push(callback);
	}

	public function notifyOnExited(callback:Void->Void) {
		exitListeners.push(callback);
	}

	public function notifyOnPressed(callback:Void->Void) {
		pressListeners.push(callback);
	}

	public function notifyOnReleased(callback:Void->Void) {
		releaseListeners.push(callback);
	}

	public function notifyOnClicked(callback:Void->Void) {
		clickListeners.push(callback);
	}

	function set_entered(value:Bool):Bool {
		if (value != entered) {
			entered = value;
			if (entered)
				for (callback in enterListeners)
					callback();
			else
				for (callback in exitListeners)
					callback();
		}
		return entered;
	}

	function set_pressed(value:Bool):Bool {
		if (value != pressed) {
			pressed = value;
			if (pressed)
				for (callback in pressListeners)
					callback();
			else
				for (callback in releaseListeners)
					callback();
		}
		return pressed;
	}
}
