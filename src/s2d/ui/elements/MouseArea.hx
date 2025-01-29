package s2d.ui.elements;

import kha.Canvas;

class MouseArea extends UIElement {
	@:isVar public var entered(default, set):Bool = false;

	var enteredListeners:Array<Void->Void> = [];
	var exitedListeners:Array<Void->Void> = [];

	public function new(?scene:UIScene) {
		super(scene);
		App.input.mouse.notifyOnMove((dx, dy) -> {
			final p = finalModel.inverse().multvec({x: App.input.mouse.x, y: App.input.mouse.y});
			final mx = p.x - x;
			final my = p.y - y;
			if (0.0 <= mx && mx <= width && 0.0 <= my && my <= height)
				entered = true;
			else
				entered = false;
		});
	}

	public function notifyOnEntered(f:Void->Void) {
		enteredListeners.push(f);
	}

	public function notifyOnExited(f:Void->Void) {
		exitedListeners.push(f);
	}

	function set_entered(value:Bool):Bool {
		if (value != entered) {
			entered = value;
			if (entered)
				for (f in enteredListeners)
					f();
			else
				for (f in exitedListeners)
					f();
		}
		return entered;
	}
}
