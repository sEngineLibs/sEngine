package s2d.ui.elements;

import kha.Canvas;
// s2d
import s2d.core.S2DObject;
import s2d.Color;
import s2d.math.Vec2;
import s2d.math.VectorMath;
import s2d.geometry.Rect;
import s2d.geometry.Size;
import s2d.ui.positioning.Anchors;

@:allow(s2d.ui.UIScene)
class UIElement extends S2DObject<UIElement> {
	overload extern public static inline function mapToElement(element:UIElement, x:Float, y:Float):Vec2 {
		return element.mapFromGlobal(x, y);
	}

	overload extern public static inline function mapFromElement(element:UIElement, x:Float, y:Float):Vec2 {
		return element.mapToGlobal(x, y);
	}

	var scene:UIScene;

	public var focused:Bool = false;
	public var visible:Bool = true;
	public var color:Color = white;
	public var opacity:Float = 1.0;
	public var enabled:Bool = true;
	public var clip:Bool = false;

	var finalOpacity(get, never):Float;

	// anchors
	public var anchors:Anchors;
	public var left:AnchorLine = {dir: 1.0};
	public var top:AnchorLine = {dir: 1.0};
	public var right:AnchorLine = {dir: -1.0};
	public var bottom:AnchorLine = {dir: -1.0};
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

	public var rect(get, never):Rect;
	public var size(get, never):Size;

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

	public function mapFromGlobal(x:Float, y:Float):Vec2 {
		var p:Vec2 = (finalModel * vec3(x, y, 1.0)).xy;
		return p;
	}

	public function mapToGlobal(x:Float, y:Float):Vec2 {
		var p:Vec2 = (inverse(finalModel) * vec3(x, y, 1.0)).xy;
		return p;
	}

	public function childAt(x:Float, y:Float):UIElement {
		var c:UIElement = null;
		for (i in 1...children.length + 1) {
			final child = children[children.length - i];
			final e = child.childAt(x, y);

			if (e != null) {
				c = e;
				break;
			} else if (child.contains(x, y)) {
				c = child;
				break;
			}
		}
		return c;
	}

	public function contains(x:Float, y:Float):Bool {
		final _p = mapToGlobal(x, y);
		final _x = _p.x - this.x;
		final _y = _p.y - this.y;
		return 0.0 <= _x && _x <= width && 0.0 <= _y && _y <= height;
	}

	function render(target:Canvas) {
		if (visible) {
			final g2 = target.g2;

			g2.color = color;
			g2.opacity = finalOpacity;
			g2.transformation = finalModel;
			draw(target);
			#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
			g2.color = White;
			g2.opacity = 0.75;
			g2.drawRect(x, y, width, height, 2.0);
			#end
			for (child in children)
				child.render(target);
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
			if (element.finalZ >= finalZ) {
				parent.children.insert(i, this);
				break;
			}
			++i;
		}
	}

	function onTransformationChanged() {}

	function get_rect():Rect {
		return {
			x: x,
			y: y,
			z: width,
			w: height
		};
	}

	function get_size():Size {
		return {
			x: width,
			y: height
		};
	}

	function get_finalOpacity():Float {
		return parent == null ? opacity : parent.finalOpacity * opacity;
	}

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
