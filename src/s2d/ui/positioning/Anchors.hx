package s2d.ui.positioning;

import s2d.ui.elements.UIElement;

class Anchors {
	public var left:AnchorLine = null;
	public var top:AnchorLine = null;
	public var right:AnchorLine = null;
	public var bottom:AnchorLine = null;

	@:isVar public var margins(default, set):Float = 0.0;

	public function new(element:UIElement) {
		left = element.left;
		top = element.top;
		right = element.right;
		bottom = element.bottom;
	}

	public function fill(element:UIElement) {
		left.bind = element.left;
		top.bind = element.top;
		right.bind = element.right;
		bottom.bind = element.bottom;
	}

	public function setMargins(value:Float):Void {
		margins = value;
	}

	function set_margins(value:Float) {
		margins = value;
		left.margin = value;
		top.margin = value;
		right.margin = value;
		bottom.margin = value;
		return value;
	}
}

@:allow(s2d.ui.positioning.Anchors)
@:structInit
class AnchorLine {
	var bind:AnchorLine = null;
	var dir:Float;

	@:isVar public var position(get, set):Float = 0.0;
	public var padding:Float = 0.0;
	public var margin:Float = 0.0;

	function get_position():Float {
		return bind == null ? position : bind.position + (bind.padding + margin) * dir;
	}

	function set_position(value:Float):Float {
		if (bind == null)
			position = value;
		return value;
	}
}
