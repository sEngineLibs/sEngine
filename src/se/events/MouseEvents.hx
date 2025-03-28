package se.events;

import se.input.Mouse.MouseButton;

typedef MouseEvent = {
	var ?accepted:Bool;
}

typedef MouseScrollEvent = {
	> MouseEvent,
	var delta:Int;
}

typedef MouseMoveEvent = {
	> MouseEvent,
	var x:Int;
	var y:Int;
	var dx:Int;
	var dy:Int;
}

typedef MouseButtonEvent = {
	> MouseEvent,
	var button:MouseButton;
	var x:Int;
	var y:Int;
}
