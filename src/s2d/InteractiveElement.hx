package s2d;

import kha.input.KeyCode;
import se.input.Mouse;
import se.events.MouseEvents;
import s2d.FocusPolicy;

class InteractiveElement extends Element {
	public var focusPolicy:FocusPolicy = ClickFocus | TabFocus;
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

	public function new(?scene:WindowScene) {
		super(scene);
		this.scene.interactives.unshift(this);

		onKeyboardDown(keyboardKeyDown.emit);
		onKeyboardUp(keyboardKeyUp.emit);
		onKeyboardHold(keyboardKeyHold.emit);
		onKeyboardPressed(keyboardCharPressed.emit);

		onMouseDown(m -> mouseButtonDown(m.button, m));
		onMouseUp(m -> mouseButtonUp(m.button, m));
		onMouseHold(m -> mouseButtonHold(m.button, m));
		onMouseClicked(m -> {
			mouseButtonClicked(m.button, m);
			if (!focused && (focusPolicy & ClickFocus != 0))
				this.scene.focused = this;
		});
		onMouseDoubleClicked(m -> mouseButtonDoubleClicked(m.button, m));
	}
}
