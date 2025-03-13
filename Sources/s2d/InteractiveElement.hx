package s2d;

import se.system.input.Mouse;
import se.events.MouseEvents;

class InteractiveElement extends Element {
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
		scene.interactives.add(this);

		onMouseDown(m -> mouseButtonDown.emit(m.button, m));
		onMouseUp(m -> mouseButtonUp.emit(m.button, m));
		onMouseHold(m -> mouseButtonHold.emit(m.button, m));
		onMouseClicked(m -> mouseButtonClicked.emit(m.button, m));
		onMouseDoubleClicked(m -> mouseButtonDoubleClicked.emit(m.button, m));
	}
}
