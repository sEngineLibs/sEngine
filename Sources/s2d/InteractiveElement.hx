package s2d;

import kha.input.KeyCode;
import se.input.Mouse;
import se.events.MouseEvents;

class InteractiveElement extends Element {
	public var focusPolicy:FocusPolicy = StrongFocus;
	@track public var focused:Bool = false;
	@track public var enabled:Bool = true;

	@:signal function keyboardDown(key:KeyCode);

	@:signal function keyboardUp(key:KeyCode);

	@:signal function keyboardHold(key:KeyCode);

	@:signal function keyboardPressed(char:String);

	@:signal(key) function keyboardKeyDown(key:KeyCode);

	@:signal(key) function keyboardKeyUp(key:KeyCode);

	@:signal(key) function keyboardKeyHold(key:KeyCode);

	@:signal(char) function keyboardCharPressed(char:String);

	@:signal function mouseMoved(m:MouseMoveEvent);

	@:signal function mouseScrolled(m:MouseScrollEvent);

	@:signal function mouseDown(m:MouseButtonEvent);

	@:signal function mouseUp(m:MouseButtonEvent);

	@:signal function mouseHold(m:MouseButtonEvent);

	@:signal function mouseClicked(m:MouseButtonEvent);

	@:signal function mouseDoubleClicked(m:MouseButtonEvent);

	@:signal(button) function mouseButtonDown(button:MouseButton, m:MouseButtonEvent);

	@:signal(button) function mouseButtonUp(button:MouseButton, m:MouseButtonEvent);

	@:signal(button) function mouseButtonHold(button:MouseButton, m:MouseButtonEvent);

	@:signal(button) function mouseButtonClicked(button:MouseButton, m:MouseButtonEvent);

	@:signal(button) function mouseButtonDoubleClicked(button:MouseButton, m:MouseButtonEvent);

	public inline function new(?parent:Element) {
		super(parent);
		scene.interactives.unshift(this);

		onKeyboardDown(keyboardKeyDown.emit);
		onKeyboardUp(keyboardKeyUp.emit);
		onKeyboardHold(keyboardKeyHold.emit);
		onKeyboardPressed(keyboardCharPressed.emit);

		onMouseDown(m -> mouseButtonDown.emit(m.button, m));
		onMouseUp(m -> mouseButtonUp.emit(m.button, m));
		onMouseHold(m -> mouseButtonHold.emit(m.button, m));
		onMouseClicked(m -> mouseButtonClicked.emit(m.button, m));
		onMouseDoubleClicked(m -> mouseButtonDoubleClicked.emit(m.button, m));
	}
}

enum abstract FocusPolicy(Int) from Int to Int {
	var NoFocus;
	var TabFocus;
	var ClickFocus;
	var StrongFocus = TabFocus | ClickFocus;
	var WheelFocus = StrongFocus | 4;
}
