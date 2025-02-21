package se.s2d.ui;

import se.s2d.ui.elements.UIElement;

class Anchors {
	public var left:AnchorLine = null;
	public var top:AnchorLine = null;
	public var right:AnchorLine = null;
	public var bottom:AnchorLine = null;

	public var leftMargin:Float = 0.0;
	public var topMargin:Float = 0.0;
	public var rightMargin:Float = 0.0;
	public var bottomMargin:Float = 0.0;
	@:isVar public var margins(default, set):Float = 0.0;

	public function new() {}

	public function fill(element:UIElement) {
		left = element.left;
		top = element.top;
		right = element.right;
		bottom = element.bottom;
	}

	public function setMargins(value:Float):Void {
		margins = value;
	}

	function set_margins(value:Float) {
		margins = value;
		leftMargin = value;
		topMargin = value;
		rightMargin = value;
		bottomMargin = value;
		return value;
	}
}

@:structInit
class AnchorLine {
	public var position:Float = 0.0;
	public var padding:Float = 0.0;
}
