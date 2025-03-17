package s2d;

import s2d.geometry.Size;
import se.Texture;
import se.math.VectorMath;
import s2d.Anchors;
import s2d.geometry.Rect;
import s2d.geometry.Bounds;
import s2d.geometry.Position;

@:allow(s2d.WindowScene)
class Element extends Object2D<Element> {
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

	public var layout:ElementLayout = new ElementLayout();
	public var visible:Bool = true;
	public var opacity:Float = 1.0;

	// geometry
	@track public var x(get, set):Float;
	@track public var y(get, set):Float;
	@track public var width(get, set):Float;
	@track public var height(get, set):Float;
	@:isVar public var minWidth(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxWidth(default, set):Float = Math.POSITIVE_INFINITY;
	@:isVar public var minHeight(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxHeight(default, set):Float = Math.POSITIVE_INFINITY;

	public var size(get, set):Size;
	public var position(get, set):Position;
	public var bounds(get, set):Bounds;
	public var contentBounds(get, set):Bounds;
	@alias public var rect:Rect = bounds;
	@alias public var contentRect:Rect = contentBounds;

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

	public function setBounds(bounds:Bounds) {
		this.bounds = bounds;
	}

	overload extern public inline function setSize(width:Float, height:Float):Void {
		setSize(new Size(width, height));
	}

	overload extern public inline function setSize(size:Size):Void {
		this.size = size;
	}

	overload extern public inline function setPosition(x:Float, y:Float):Void {
		setPosition(new Position(width, height));
	}

	overload extern public inline function setPosition(position:Position):Void {
		this.position = position;
	}

	overload extern public inline function setRect(position:Position, size:Size):Void {
		setRect(position.x, position.y, size.width, size.height);
	}

	overload extern public inline function setRect(x:Float, y:Float, width:Float, height:Float):Void {
		setRect(new Rect(x, y, width, height));
	}

	overload extern public inline function setRect(rect:Rect):Void {
		this.rect = rect;
	}

	overload extern public inline function mapFromGlobal(p:Position):Position {
		return globalTransform * p;
	}

	overload extern public inline function mapFromGlobal(x:Float, y:Float):Position {
		return mapFromGlobal(vec2(x, y));
	}

	overload extern public inline function mapToGlobal(p:Position):Position {
		return inverse(globalTransform) * p;
	}

	overload extern public inline function mapToGlobal(x:Float, y:Float):Position {
		return mapToGlobal(vec2(x, y));
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
		return bounds.contains(mapToGlobal(x, y));
	}

	@:slot(parentChanged)
	function syncWithParent(previous:Element) {
		x += (parent?.x ?? 0.0) - (previous?.x ?? 0.0);
		y += (parent?.y ?? 0.0) - (previous?.y ?? 0.0);
	}

	function render(target:Texture) {
		final ctx = target.ctx2D;
		ctx.style.pushOpacity(opacity);
		ctx.transform = globalTransform;
		for (c in children)
			if (c.visible)
				c.render(target);
		ctx.style.popOpacity();
	}

	inline function get_anchors():Anchors {
		return this;
	}

	inline function set_padding(value:Float) {
		left.padding = value;
		top.padding = value;
		right.padding = value;
		bottom.padding = value;
		return value;
	}

	inline function get_x():Float {
		return left.position;
	}

	inline function set_x(value:Float):Float {
		final d = value - x;
		left.position = value;
		if (anchors.right == null)
			right.position += d;
		for (c in children)
			c.x += d;
		return value;
	}

	inline function get_y():Float {
		return top.position;
	}

	inline function set_y(value:Float):Float {
		final d = value - y;
		top.position = value;
		if (anchors.bottom == null)
			bottom.position += d;
		for (c in children)
			c.y += d;
		return value;
	}

	inline function get_width():Float {
		return right.position - x;
	}

	inline function set_width(value:Float):Float {
		right.position = x + clamp(value, minWidth, maxWidth);
		return value;
	}

	inline function get_height():Float {
		return bottom.position - y;
	}

	inline function set_height(value:Float):Float {
		bottom.position = y + clamp(value, minHeight, maxHeight);
		return value;
	}

	inline function set_minWidth(value:Float):Float {
		if (value != minWidth) {
			minWidth = value;
			width = width;
		}
		return minWidth;
	}

	inline function set_maxWidth(value:Float):Float {
		if (value != maxWidth) {
			maxWidth = value;
			width = width;
		}
		return maxWidth;
	}

	inline function set_minHeight(value:Float):Float {
		if (value != minHeight) {
			minHeight = value;
			height = height;
		}
		return minHeight;
	}

	inline function set_maxHeight(value:Float):Float {
		if (value != maxHeight) {
			maxHeight = value;
			height = height;
		}
		return maxHeight;
	}

	inline function get_size():Size {
		return new Size(width, height);
	}

	inline function set_size(value:Size):Size {
		width = value.width;
		height = value.height;
		return value;
	}

	inline function get_position():Position {
		return new Position(x, y);
	}

	inline function set_position(value:Position):Position {
		x = value.x;
		y = value.y;
		return value;
	}

	inline function get_bounds():Bounds {
		return new Bounds(left.position, top.position, right.position, bottom.position);
	}

	inline function set_bounds(value:Bounds):Bounds {
		left.position = value.left;
		top.position = value.top;
		right.position = value.right;
		bottom.position = value.bottom;
		return value;
	}

	inline function get_contentBounds():Bounds {
		return new Bounds(left.position
			+ left.padding, top.position
			+ top.padding, right.position
			- right.padding, bottom.position
			- bottom.padding);
	}

	inline function set_contentBounds(value:Bounds):Bounds {
		left.position = value.left - left.padding;
		top.position = value.top - top.padding;
		right.position = value.right + right.padding;
		bottom.position = value.bottom + bottom.padding;
		return value;
	}
}
