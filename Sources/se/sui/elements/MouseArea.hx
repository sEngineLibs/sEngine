package se.sui.elements;

import se.system.Time;
import se.system.Application;
import se.system.input.Mouse;

class MouseArea extends UIElement {
	public var entered:Bool = false;
	public var pressed:Bool = false;

	public var acceptedButtons:Array<MouseButton> = [MouseButton.Left];
	public var doubleClickInterval:Float = 0.5;

	var pressedButtons:Map<MouseButton, Float> = [];

	var enterListeners:Array<(x:Int, y:Int) -> Void> = [];
	var exitListeners:Array<(x:Int, y:Int) -> Void> = [];
	var pressListeners:Array<(button:MouseButton, x:Int, y:Int) -> Void> = [];
	var releaseListeners:Array<(button:MouseButton, x:Int, y:Int) -> Void> = [];
	var clickListeners:Array<(button:MouseButton, x:Int, y:Int) -> Void> = [];
	var doubleClickListeners:Array<(button:MouseButton, x:Int, y:Int) -> Void> = [];

	public function new(?scene:UIScene) {
		super(scene);
		Application.input.mouse.notifyOnMoved((mx, my, dx, dy) -> {
			final p = mapToGlobal(mx, my);
			final _x = p.x - x;
			final _y = p.y - y;
			if (0.0 <= _x && _x <= width && 0.0 <= _y && _y <= height) {
				if (!entered) {
					entered = true;
					for (callback in enterListeners)
						callback(mx, my);
				}
			} else {
				if (entered) {
					entered = false;
					for (callback in exitListeners)
						callback(mx, my);
				}
			}
		});
		Application.input.mouse.notifyOnDown((button, x, y) -> {
			if (acceptedButtons.contains(button))
				if (entered)
					press(button, x, y);
		});
		Application.input.mouse.notifyOnUp((button, x, y) -> {
			if (acceptedButtons.contains(button)) {
				release(button, x, y);
				if (entered)
					click(button, x, y);
			}
		});
	}

	public function press(button:MouseButton, x:Int, y:Int) {
		if (!pressed) {
			pressed = true;
			for (callback in pressListeners)
				callback(button, x, y);
			var time = Time.realTime;
			if (time - pressedButtons[button] <= doubleClickInterval)
				for (doubleClickListener in doubleClickListeners)
					doubleClickListener(button, x, y);
			else
				pressedButtons[button] = time;
		}
	}

	public function release(button:MouseButton, x:Int, y:Int) {
		if (pressed) {
			pressed = false;
			for (callback in releaseListeners)
				callback(button, x, y);
		}
	}

	public function click(button:MouseButton, x:Int, y:Int) {
		for (callback in clickListeners)
			callback(button, x, y);
	}

	public function notifyOnEntered(callback:(x:Int, y:Int) -> Void) {
		enterListeners.push(callback);
	}

	public function notifyOnExited(callback:(x:Int, y:Int) -> Void) {
		exitListeners.push(callback);
	}

	public function notifyOnPressed(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		pressListeners.push(callback);
	}

	public function notifyOnReleased(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		releaseListeners.push(callback);
	}

	public function notifyOnClicked(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		clickListeners.push(callback);
	}

	public function notifyOnDoubleClicked(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		doubleClickListeners.push(callback);
	}

	public function removeCallbackOnDoubleClicked(callback:(button:MouseButton, x:Int, y:Int) -> Void) {
		doubleClickListeners.remove(callback);
	}
}
