package s2d.elements;

import se.App;
import se.Set;
import se.system.input.Mouse;

class MouseArea extends Element {
	var buttonsPressed:Map<MouseButton, Int> = [];

	public var acceptedButtons:Set<MouseButton> = [MouseButton.Left];
	public var doubleClickInterval:Float = 0.5;

	public var isEntered:Bool = false;
	@:track public var mouseX:Float = 0.0;
	@:track public var mouseY:Float = 0.0;

	@:signal function entered(x:Int, y:Int);

	@:signal function exited(x:Int, y:Int);

	@:signal function moved(dx:Float, dy:Float);

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

	public function new(?parent:Element) {
		super(parent);

		var m = App.input.mouse;
		m.onMoved(_moved);
		m.onScrolled(d -> {
			if (isEntered)
				scrolled(d);
		});

		onEntered((x, y) -> isEntered = true);
		onExited((x, y) -> isEntered = false);
		onDown(buttonDown.emit);
		onUp(buttonUp.emit);
		onClicked(buttonClicked.emit);
		onDoubleClicked(buttonDoubleClicked.emit);
	}

	public inline function isPressed(button:MouseButton):Bool {
		return buttonsPressed.exists(button);
	}

	function _moved(x:Int, y:Int, dx:Int, dy:Int) {
		var p = mapToGlobal(x, y);
		p.x -= this.x;
		p.y -= this.y;

		if (0.0 <= p.x && p.x <= width && 0.0 <= p.y && p.y <= height) {
			mouseX = p.x;
			mouseY = p.y;
			trace(mouseX, mouseY);

			if (!isEntered)
				entered(x, y);
			var dp = mapFromGlobal(dx, dy);
			moved(dp.x, dp.y);
		} else {
			if (isEntered)
				exited(x, y);
		}
	}

	@:slot(down) function _down(button:MouseButton, x:Int, y:Int) {
		if (isAccepted(button))
			down(button, x, y);
	}

	@:slot(up) function _up(button:MouseButton, x:Int, y:Int) {
		if (isAccepted(button))
			up(button, x, y);
	}

	@:slot(clicked) function _clicked(button:MouseButton) {
		if (isAccepted(button))
			clicked(button);
	}

	@:slot(doubleClicked) function _doubleClicked(button:MouseButton) {
		if (isAccepted(button))
			doubleClicked(button);
	}

	inline function isAccepted(button:MouseButton):Bool {
		return isEntered && acceptedButtons.contains(button);
	}
}
