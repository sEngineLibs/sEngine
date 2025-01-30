package s2d.ui.elements;

import kha.Canvas;

class MouseArea extends UIElement {
	@:isVar public var entered(default, set):Bool = false;
	@:isVar public var pressed(default, set):Bool = false;

	var enterListeners:Array<Void->Void> = [];
	var exitListeners:Array<Void->Void> = [];
	var pressListeners:Array<Void->Void> = [];
	var releaseListeners:Array<Void->Void> = [];
	var clickListeners:Array<Void->Void> = [];

	public function new(?scene:UIScene) {
		super(scene);
		App.input.mouse.notifyOnMoved((dx, dy) -> {
			final p = finalModel.inverse().multvec({x: App.input.mouse.x, y: App.input.mouse.y});
			final mx = p.x - x;
			final my = p.y - y;
			if (0.0 <= mx && mx <= width && 0.0 <= my && my <= height)
				entered = true;
			else
				entered = false;
		});

		App.input.mouse.notifyOnDown((button) -> {
			if (entered)
				press();
		});

		App.input.mouse.notifyOnUp((button) -> {
			release();
			if (entered)
				click();
		});
	}

	public function press() {
		pressed = true;
	}

	public function release() {
		pressed = false;
	}

	public function click() {
		for (f in clickListeners)
			f();
	}

	public function notifyOnEntered(f:Void->Void) {
		enterListeners.push(f);
	}

	public function notifyOnExited(f:Void->Void) {
		exitListeners.push(f);
	}

	public function notifyOnPressed(f:Void->Void) {
		pressListeners.push(f);
	}

	public function notifyOnReleased(f:Void->Void) {
		releaseListeners.push(f);
	}

	public function notifyOnClicked(f:Void->Void) {
		clickListeners.push(f);
	}

	function set_entered(value:Bool):Bool {
		if (value != entered) {
			entered = value;
			if (entered)
				for (f in enterListeners)
					f();
			else
				for (f in exitListeners)
					f();
		}
		return entered;
	}

	function set_pressed(value:Bool):Bool {
		if (value != pressed) {
			pressed = value;
			if (pressed)
				for (f in pressListeners)
					f();
			else
				for (f in releaseListeners)
					f();
		}
		return pressed;
	}
}
