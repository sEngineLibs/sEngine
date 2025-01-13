package sui.elements;

import kha.Color;
import kha.Canvas;

class DrawableElement extends Element {
	public var visible:Bool = true;
	public var opacity:Float = 1;
	public var finalOpacity(get, never):Float;
	@:isVar public var color(default, set):Color = Color.White;

	function set_color(value:Color) {
		color = value;
		return color;
	}

	function get_finalOpacity():Float {
		if (parent is DrawableElement)
			return opacity * cast(parent, DrawableElement).finalOpacity;
		return opacity;
	}

	public function render(target:Canvas, ?clear:Bool = true) {}
}
