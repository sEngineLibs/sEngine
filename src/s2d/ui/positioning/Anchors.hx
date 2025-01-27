package s2d.ui.positioning;

import s2d.ui.elements.UIElement;

class Anchors {
	public var left:AnchorLine = null;
	public var top:AnchorLine = null;
	public var right:AnchorLine = null;
	public var bottom:AnchorLine = null;
	@:isVar public var margins(default, set):Float = 0;
	@:isVar public var padding(default, set):Float = 0;
	public var verticalCenter:AnchorLine = null;
	public var horizontalCenter:AnchorLine = null;
	public var verticalCenterOffset:Float = 0;
	public var horizontalCenterOffset:Float = 0;

	public function new() {}

	public function fill(element:UIElement) {
		left = element.left;
		top = element.top;
		right = element.right;
		bottom = element.bottom;
	}

	public function centerIn(element:UIElement) {
		horizontalCenter = element.horizontalCenter;
		verticalCenter = element.verticalCenter;
	}

	public function setMargins(value:Float):Void {
		margins = value;
	}

	public function setPadding(value:Float):Void {
		padding = value;
	}

	function set_margins(value:Float) {
		margins = value;
		left.margin = value;
		top.margin = value;
		right.margin = value;
		bottom.margin = value;
		return value;
	}

	function set_padding(value:Float) {
		padding = value;
		left.padding = value;
		top.padding = value;
		right.padding = value;
		bottom.padding = value;
		return value;
	}
}

@:structInit
class AnchorLine {
	public var position:Float;
	public var margin:Float;
	public var padding:Float;

	public inline function new(?position:Float = 0, ?margin:Float = 0, ?padding:Float = 0) {
		this.position = position;
		this.margin = margin;
		this.padding = padding;
	}
}
