package se.events;

typedef MouseEvent = {
	var accepted:Bool;
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
	var button:Int;
	var x:Int;
	var y:Int;
}
