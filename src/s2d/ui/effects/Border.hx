package s2d.ui.effects;

import s2d.Color;

@:structInit
class Border {
	public var color:Color = "black";
	@:isVar public var width(default, set):Float = -1.0;
	@:isVar public var softness(default, set):Float = 1.0;

	function set_width(value:Float):Float {
		width = Math.max(value, -1.0);
		return value;
	}

	function set_softness(value:Float):Float {
		softness = Math.max(value, 0.0);
		return value;
	}
}
