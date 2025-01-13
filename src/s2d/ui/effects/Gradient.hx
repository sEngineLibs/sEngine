package sui.effects;

import kha.Color;

@:structInit
class Gradient {
	public var alignByElement:Bool = true;
	public var start:Color = Color.White;
	public var end:Color = Color.Black;
	public var angle:Float = 90;
	public var position:Float = 0.5;
	public var scale:Float = 1.0;
}
