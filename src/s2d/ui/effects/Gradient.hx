package s2d.ui.effects;

import s2d.Color;

@:structInit
class Gradient {
	public var alignByElement:Bool = true;
	public var start:Color = "white";
	public var end:Color = "black";
	public var angle:Float = 90;
	public var position:Float = 0.5;
	public var scale:Float = 1.0;
}
