package s2d.ui.elements;

import se.App;
import se.Set;
import se.system.input.Mouse;

class MouseArea extends UISceneElement {
	var buttonsPressed:Map<MouseButton, Int> = [];

	public var isEntered:Bool = false;

	public var acceptedButtons:Set<MouseButton> = [MouseButton.Left];
	public var doubleClickInterval:Float = 0.5;

	@:signal function entered(x:Int, y:Int);

	@:signal function exited(x:Int, y:Int);

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

	public function new(?parent:UIElement) {
		super(parent);
		var m = App.input.mouse;

		onEntered((x, y) -> isEntered = true);
		onExited((x, y) -> isEntered = false);
		onDown(buttonDown.emit);
		onUp(buttonUp.emit);
		onClicked(buttonClicked.emit);
		onDoubleClicked(buttonDoubleClicked.emit);

		m.onScrolled(d -> {
			if (isEntered)
				scrolled(d);
		});

		m.onMoved((mx, my, dx, dy) -> {
			if (this.contains(mx, my))
				entered(mx, my);
			else
				exited(mx, my);
		});

		m.onDown((button, x, y) -> {
			if (inline isAccepted(button))
				down(button, x, y);
		});

		m.onUp((button, x, y) -> {
			if (inline isAccepted(button))
				up(button, x, y);
		});

		m.onClicked((button) -> {
			if (inline isAccepted(button))
				clicked(button);
		});

		m.onDoubleClicked((button) -> {
			if (inline isAccepted(button))
				doubleClicked(button);
		});
	}

	public inline function isPressed(button:MouseButton):Bool {
		return buttonsPressed.exists(button);
	}

	function isAccepted(button:MouseButton):Bool {
		return isEntered && acceptedButtons.contains(button);
	}
}
