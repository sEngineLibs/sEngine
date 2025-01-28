package s2d.ui.elements;

import kha.Color;
import kha.Canvas;
// s2d
import s2d.core.S2DObject;
import s2d.core.utils.MathUtils;
import s2d.ui.positioning.Anchors;

abstract class UIElement extends S2DObject<UIElement> {
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

	public function new(scene:UIScene) {
		super();
		this.scene = scene;
		this.scene.addBaseElement(this);
	}

	public function resize(w:Int, h:Int) {
		width = w;
		height = h;
	}

	public function render(target:Canvas) {
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

	abstract function draw(target:Canvas):Void;

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
		return left.position;
	}

	function set_x(value:Float):Float {
		var d = value - x;
		left.position = value;
		horizontalCenter.position += d / 2;
		right.position += d;
		return value;
	}

	function get_y():Float {
		return top.position;
	}

	function set_y(value:Float):Float {
		var d = value - y;
		top.position = value;
		verticalCenter.position += d / 2;
		bottom.position += d;
		return value;
	}

	function get_centerX():Float {
		return horizontalCenter.position;
	}

	function set_centerX(value:Float):Float {
		var d = value - centerX;
		left.position += d;
		horizontalCenter.position = value;
		right.position += d;
		return value;
	}

	function get_centerY():Float {
		return verticalCenter.position;
	}

	function set_centerY(value:Float):Float {
		var d = value - centerY;
		top.position += d;
		verticalCenter.position = value;
		bottom.position += d;
		return value;
	}

	function get_width():Float {
		return right.position - x;
	}

	function set_width(value:Float):Float {
		value = clamp(value, minWidth, maxWidth);
		horizontalCenter.position = x + value / 2;
		right.position = x + value;
		return value;
	}

	function get_height():Float {
		return bottom.position - y;
	}

	function set_height(value:Float):Float {
		value = clamp(value, minHeight, maxHeight);
		verticalCenter.position = y + value / 2;
		bottom.position = y + value;
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
}
