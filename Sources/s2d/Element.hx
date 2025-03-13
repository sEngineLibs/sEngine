package s2d;

import se.Color;
import se.Texture;
import se.math.Vec2;
import se.math.Vec4;
import se.math.Mat3;
import se.math.VectorMath;
import s2d.Anchors;
import s2d.geometry.Size;
import s2d.geometry.Rect;
import s2d.geometry.Bounds;
import s2d.geometry.Position;

@:allow(s2d.WindowScene)
class Element extends PhysicalObject<Element> {
	overload extern public static inline function mapToElement(element:Element, x:Float, y:Float):Position {
		return element.mapFromGlobal(x, y);
	}

	overload extern public static inline function mapToElement(element:Element, p:Position):Position {
		return element.mapFromGlobal(p.x, p.y);
	}

	overload extern public static inline function mapFromElement(element:Element, x:Float, y:Float):Position {
		return element.mapToGlobal(x, y);
	}

	overload extern public static inline function mapFromElement(element:Element, p:Position):Position {
		return element.mapToGlobal(p.x, p.y);
	}

	var scene:WindowScene;

	public var left:AnchorLine = new AnchorLine(1.0);
	public var top:AnchorLine = new AnchorLine(1.0);
	public var right:AnchorLine = new AnchorLine(-1.0);
	public var bottom:AnchorLine = new AnchorLine(-1.0);
	public var anchors(get, never):Anchors;
	public var padding(never, set):Float;

	public var layout:Layout = new Layout();
	public var visible:Bool = true;
	public var opacity:Float = 1.0;
	public var color:Color = White;

	@track public var x(get, set):Float;
	@track public var y(get, set):Float;
	@track public var width(get, set):Float;
	@track public var height(get, set):Float;
	@:isVar public var minWidth(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxWidth(default, set):Float = Math.POSITIVE_INFINITY;
	@:isVar public var minHeight(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxHeight(default, set):Float = Math.POSITIVE_INFINITY;

	public var rect(get, set):Rect;
	public var bounds(get, set):Bounds;
	public var contentRect(get, set):Rect;
	public var contentBounds(get, set):Bounds;
	public var childrenRect(get, never):Rect;
	public var childrenBounds(get, never):Bounds;

	public function new(?parent:Element) {
		super(parent);

		if (parent == null) {
			scene = WindowScene.current;
			scene.elements.push(this);
		} else
			scene = parent.scene;
	}

	public function setPadding(value:Float):Void {
		padding = value;
	}

	overload extern public inline function mapFromGlobal(p:Position):Position {
		return _transform * p;
	}

	overload extern public inline function mapFromGlobal(x:Float, y:Float):Position {
		return mapFromGlobal(vec2(x, y));
	}

	overload extern public inline function mapToGlobal(p:Position):Position {
		return inverse(_transform) * p;
	}

	overload extern public inline function mapToGlobal(x:Float, y:Float):Position {
		return mapToGlobal(vec2(x, y));
	}

	overload extern public inline function setPosition(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}

	overload extern public inline function setPosition(value:Vec2):Void {
		this.x = value.x;
		this.y = value.y;
	}

	overload extern public inline function setSize(width:Float, height:Float) {
		this.width = width;
		this.height = height;
	}

	overload extern public inline function setSize(value:Vec2) {
		this.width = value.x;
		this.height = value.y;
	}

	overload extern public inline function setRect(value:Rect):Void {
		setPosition(rect.position);
		setSize(rect.size);
	}

	overload extern public inline function setRect(position:Position, size:Size):Void {
		setPosition(position);
		setSize(size);
	}

	overload extern public inline function setRect(x:Float, y:Float, width:Float, height:Float):Void {
		setPosition(x, y);
		setSize(width, height);
	}

	public function setContentRect(value:Rect):Void {
		left.padding = value.x - x;
		top.padding = value.y - y;
		right.padding = width - left.padding - value.width;
		bottom.padding = height - top.padding - value.height;
	}

	public function setBounds(value:Bounds):Void {
		setRect(value.toRect());
	}

	public function setContentBounds(value:Bounds):Void {
		setContentRect(value.toRect());
	}

	public function childAt(x:Float, y:Float):Element {
		var i = children.length;
		while (0 < i) {
			final c = children[--i];
			if (c.contains(x, y))
				return c;
		}
		return null;
	}

	public function descendantAt(x:Float, y:Float):Element {
		var i = children.length;
		while (0 < i) {
			final c = children[--i];
			var cat = c.descendantAt(x, y);
			if (cat == null) {
				if (c.contains(x, y))
					return c;
			} else
				return cat;
		};
		return null;
	}

	public function contains(x:Float, y:Float):Bool {
		final p = mapToGlobal(x, y);
		return this.x <= p.x && p.x <= width && this.y <= p.y && p.y <= height;
	}

	function draw(target:Texture):Void {}

	function render(target:Texture) {
		if (visible) {
			final ctx = target.ctx2D;

			ctx.style.color = color;
			ctx.style.pushOpacity(opacity);
			ctx.pushTransformation(transform);
			_transform.copyFrom(ctx.transform);

			draw(target);
			for (c in children)
				c.render(target);

			ctx.style.popOpacity();
			ctx.popTransformation();
		}
	}

	private inline function get_anchors():Anchors {
		return this;
	}

	private inline function set_padding(value:Float) {
		left.padding = value;
		top.padding = value;
		right.padding = value;
		bottom.padding = value;
		return value;
	}

	private inline function get_x():Float {
		return left.position;
	}

	private inline function set_x(value:Float):Float {
		final d = value - x;
		left.position = value;
		if (anchors.right == null)
			right.position += d;
		for (c in children)
			c.x += d;
		return value;
	}

	private inline function get_y():Float {
		return top.position;
	}

	private inline function set_y(value:Float):Float {
		final d = value - y;
		top.position = value;
		if (anchors.bottom == null)
			bottom.position += d;
		for (c in children)
			c.y += d;
		return value;
	}

	private inline function get_width():Float {
		return right.position - x;
	}

	private inline function set_width(value:Float):Float {
		right.position = x + clamp(value, minWidth, maxWidth);
		return value;
	}

	private inline function get_height():Float {
		return bottom.position - y;
	}

	private inline function set_height(value:Float):Float {
		bottom.position = y + clamp(value, minHeight, maxHeight);
		return value;
	}

	private inline function set_minWidth(value:Float):Float {
		if (value != minWidth) {
			minWidth = value;
			width = width;
		}
		return minWidth;
	}

	private inline function set_maxWidth(value:Float):Float {
		if (value != maxWidth) {
			maxWidth = value;
			width = width;
		}
		return maxWidth;
	}

	private inline function set_minHeight(value:Float):Float {
		if (value != minHeight) {
			minHeight = value;
			height = height;
		}
		return minHeight;
	}

	private inline function set_maxHeight(value:Float):Float {
		if (value != maxHeight) {
			maxHeight = value;
			height = height;
		}
		return maxHeight;
	}

	private inline function get_rect():Rect {
		return new Rect(x, y, width, height);
	}

	private inline function set_rect(value:Rect):Rect {
		setRect(value);
		return value;
	}

	private inline function get_bounds():Bounds {
		return rect.toBounds();
	}

	private inline function set_bounds(value:Bounds):Bounds {
		setBounds(value);
		return value;
	}

	private inline function get_contentRect():Rect {
		return new Rect(x + left.padding, y + top.padding, width - left.padding - right.padding, height - top.padding - bottom.padding);
	}

	private inline function set_contentRect(value:Rect):Rect {
		setContentRect(value);
		return value;
	}

	private inline function get_contentBounds():Bounds {
		return contentRect.toBounds();
	}

	private inline function set_contentBounds(value:Bounds):Bounds {
		setContentBounds(value);
		return value;
	}

	private inline function get_childrenBounds():Vec4 {
		var b = bounds;
		for (child in children) {
			b.left = Math.min(b.left, child.left.position);
			b.top = Math.min(b.top, child.top.position);
			b.right = Math.max(b.right, child.right.position);
			b.bottom = Math.max(b.bottom, child.bottom.position);
		}
		return b;
	}

	private inline function get_childrenRect():Vec4 {
		return childrenBounds.toRect();
	}
}
