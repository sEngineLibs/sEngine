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
	public var color:Color = White;
	public var opacity:Float = 1.0;
	public var enabled:Bool = true;
	public var clip:Bool = false;

	// anchors
	@readonly public var anchors:Anchors;
	@readonly public var left:AnchorLine = {dir: 1.0};
	@readonly public var top:AnchorLine = {dir: 1.0};
	@readonly public var right:AnchorLine = {dir: -1.0};
	@readonly public var bottom:AnchorLine = {dir: -1.0};
	@:isVar public var padding(default, set):Float = 0.0;

	// positioning
	public var x(get, set):Float;
	public var y(get, set):Float;
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
		anchors = new Anchors(this);
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
			#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
			drawBounds(target);
			#end
			if (clip)
				g2.scissor(Std.int(x), Std.int(y), Std.int(width), Std.int(height));
			for (child in children)
				child.render(target);
			if (clip)
				g2.disableScissor();
		}
	}

	function draw(target:Canvas) {}

	function drawBounds(target:Canvas) {
		final g2 = target.g2;
		final opacity = 1.5;

		// margins
		g2.color = Color.fromFloats(0.85, 0.15, 0.85, opacity);
		final lm = anchors.left == null ? 0.0 : anchors.left.margin;
		final tm = anchors.top == null ? 0.0 : anchors.top.margin;
		final rm = anchors.right == null ? 0.0 : anchors.right.margin;
		final bm = anchors.bottom == null ? 0.0 : anchors.bottom.margin;
		g2.fillRect(x - lm, y, lm, height);
		g2.fillRect(x - lm, y - tm, lm + width + rm, tm);
		g2.fillRect(x + width, y, rm, height);
		g2.fillRect(x - lm, y + height, lm + width + rm, bm);

		// padding
		g2.color = Color.fromFloats(0.85, 0.85, 0.15, opacity);
		final lp = left.padding;
		final tp = top.padding;
		final rp = right.padding;
		final bp = bottom.padding;
		g2.fillRect(x, y, lp, height);
		g2.fillRect(x + lp, y, width - lp - rp, tp);
		g2.fillRect(x + width - rp, y, rp, height);
		g2.fillRect(x + lp, y + height - bp, width - lp - rp, bp);

		// content
		g2.color = Color.fromFloats(0.15, 0.85, 0.85, opacity);
		g2.fillRect(x + lp, y + tp, width - lp - rp, height - tp - bp);
	}

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
		right.position += value - x;
		left.position = value;
		return value;
	}

	function get_y():Float {
		return top.position;
	}

	function set_y(value:Float):Float {
		bottom.position += value - y;
		top.position = value;
		return value;
	}

	function get_width():Float {
		return right.position - x;
	}

	function set_width(value:Float):Float {
		right.position = x + clamp(value, minWidth, maxWidth);
		return value;
	}

	function get_height():Float {
		return bottom.position - y;
	}

	function set_height(value:Float):Float {
		bottom.position = y + clamp(value, minHeight, maxHeight);
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
