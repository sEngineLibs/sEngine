package se.events;

import se.input.Mouse.MouseButton;

typedef MouseEvent = {
	var accepted:Bool;
	var x:Int;
	var y:Int;
}

typedef MouseButtonEvent = {
	> MouseEvent,
	var button:MouseButton;
}

typedef MouseScrollEvent = {
	> MouseEvent,
	var delta:Int;
}

typedef MouseMoveEvent = {
	> MouseEvent,
	var dx:Int;
	var dy:Int;
}
