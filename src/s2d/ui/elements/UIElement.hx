package s2d.ui.elements;

import kha.Color;
import kha.Canvas;
// s2d
import s2d.core.S2DObject;
import s2d.core.utils.MathUtils;
import s2d.ui.positioning.Anchors;

@:allow(s2d.ui.UIScene)
class UIElement extends S2DObject<UIElement> {
	var scene:UIScene;

	public var visible:Bool = true;
	public var opacity:Float = 1.0;
	public var enabled:Bool = true;
	public var clip:Bool = false;
	public var color:Color = White;

	// anchors
	@readonly public var anchors:Anchors = new Anchors();
	@readonly public var left:AnchorLine = {};
	@readonly public var top:AnchorLine = {};
	@readonly public var right:AnchorLine = {};
	@readonly public var bottom:AnchorLine = {};
	@readonly public var horizontalCenter:AnchorLine = {};
	@readonly public var verticalCenter:AnchorLine = {};
	@:isVar public var padding(default, set):Float = 0.0;

	// positioning
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var centerX(get, set):Float;
	public var centerY(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;
	@:isVar public var minWidth(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxWidth(default, set):Float = Math.POSITIVE_INFINITY;
	@:isVar public var minHeight(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxHeight(default, set):Float = Math.POSITIVE_INFINITY;

	public function new(?scene:UIScene) {
		super();
		if (scene != null)
			this.scene = scene;
		else
			this.scene = S2D.ui;
		this.scene.addBaseElement(this);
	}

	public function resize(w:Int, h:Int) {
		width = w;
		height = h;
	}

	public function setPadding(value:Float):Void {
		padding = value;
	}

	function render(target:Canvas) {
		if (visible) {
			final g2 = target.g2;

			g2.color = color;
			g2.opacity *= opacity;
			g2.transformation = finalModel;
			draw(target);

			if (clip)
				g2.scissor(Std.int(x), Std.int(y), Std.int(width), Std.int(height));
			for (child in children)
				child.render(target);
			if (clip)
				g2.disableScissor();
		}
	}

	function draw(target:Canvas) {}

	function onParentChanged() {
		if (parent == null)
			scene.addBaseElement(this);
		else
			scene.removeBaseElement(this);
	}

	function onZChanged() {
		var i = 0;
		parent.children.remove(this);
		for (element in parent.children) {
			if (element.finalZ <= finalZ) {
				parent.children.insert(i, this);
				break;
			}
			++i;
		}
	}

	function onTransformationChanged() {}

	function get_x():Float {
		return anchors.left == null ? left.position : anchors.left.position + anchors.left.padding + anchors.leftMargin;
	}

	function set_x(value:Float):Float {
		if (anchors.left == null) {
			var d = value - x;
			left.position = value;
			horizontalCenter.position += d / 2;
			right.position += d;
		}
		return value;
	}

	function get_y():Float {
		return anchors.top == null ? top.position : anchors.top.position + anchors.top.padding + anchors.topMargin;
	}

	function set_y(value:Float):Float {
		if (anchors.top == null) {
			var d = value - y;
			top.position = value;
			verticalCenter.position += d / 2;
			bottom.position += d;
		}
		return value;
	}

	function get_centerX():Float {
		return anchors.horizontalCenter == null ? horizontalCenter.position : anchors.horizontalCenter.position
			+ anchors.horizontalCenter.padding
			+ anchors.horizontalCenterOffset;
	}

	function set_centerX(value:Float):Float {
		if (anchors.horizontalCenter == null) {
			var d = value - centerX;
			left.position += d;
			horizontalCenter.position = value;
			right.position += d;
		}
		return value;
	}

	function get_centerY():Float {
		return anchors.verticalCenter == null ? verticalCenter.position : anchors.verticalCenter.position
			+ anchors.verticalCenter.padding
			+ anchors.verticalCenterOffset;
	}

	function set_centerY(value:Float):Float {
		if (anchors.verticalCenter == null) {
			var d = value - centerY;
			top.position += d;
			verticalCenter.position = value;
			bottom.position += d;
		}
		return value;
	}

	function get_width():Float {
		return anchors.right == null ? right.position - x : anchors.right.position + anchors.right.padding + anchors.rightMargin - x;
	}

	function set_width(value:Float):Float {
		if (anchors.right == null) {
			value = clamp(value, minWidth, maxWidth);
			horizontalCenter.position = x + value / 2;
			right.position = x + value;
		}
		return value;
	}

	function get_height():Float {
		return anchors.bottom == null ? bottom.position - y : anchors.bottom.position
			+ anchors.bottom.padding
			+ anchors.bottomMargin
			- y;
	}

	function set_height(value:Float):Float {
		if (anchors.bottom == null) {
			value = clamp(value, minHeight, maxHeight);
			verticalCenter.position = y + value / 2;
			bottom.position = y + value;
		}
		return value;
	}

	function set_minWidth(value:Float):Float {
		minWidth = value;
		width = width;
		return value;
	}

	function set_maxWidth(value:Float):Float {
		maxWidth = value;
		width = width;
		return value;
	}

	function set_minHeight(value:Float):Float {
		minHeight = value;
		height = height;
		return value;
	}

	function set_maxHeight(value:Float):Float {
		maxHeight = value;
		height = height;
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
