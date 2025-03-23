package s2d;

import se.Texture;
import se.math.VectorMath;
import s2d.Anchors;
import s2d.geometry.Size;
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
	public var opacity:Float = 1.0;
	@track public var visible:Bool = true;
	public var visibleChildren:Array<Element> = [];

	// geometry
	@:isVar var _x(default, set):Float = 0.0;
	@:isVar var _y(default, set):Float = 0.0;
	@:isVar var _width(default, set):Float = 0.0;
	@:isVar var _height(default, set):Float = 0.0;

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;

	@:signal function xChanged(x:Float):Void;

	@:signal function yChanged(y:Float):Void;

	@:signal function widthChanged(width:Float):Void;

	@:signal function heightChanged(height:Float):Void;

	public var bounds(get, set):Bounds;
	public var contentBounds(get, set):Bounds;
	public var rect(get, set):Rect;
	public var contentRect(get, set):Rect;

	public function new(?parent:Element) {
		super(parent);
		syncWithParent(null);

		if (parent == null) {
			scene = WindowScene.current;
			scene.elements.push(this);
		} else
			scene = parent.scene;

		left.onPositionChanged(previous -> {
			final d = left.position - previous;
			_x += d;
			if (right.isBinded)
				_width -= d;
		});
		top.onPositionChanged(previous -> {
			final d = top.position - previous;
			_y += d;
			if (bottom.isBinded)
				_height -= d;
		});
		right.onPositionChanged(previous -> _width = right.position - left.position);
		bottom.onPositionChanged(previous -> _height = bottom.position - top.position);
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
		width = size.width;
		height = size.height;
	}

	overload extern public inline function setPosition(x:Float, y:Float):Void {
		setPosition(new Position(width, height));
	}

	overload extern public inline function setPosition(position:Position):Void {
		x = position.x;
		y = position.y;
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

	function render(target:Texture) {
		final ctx = target.ctx2D;
		ctx.style.pushOpacity(opacity);
		ctx.transform = globalTransform;
		for (c in visibleChildren)
			c.render(target);
		ctx.style.popOpacity();
	}

	@:slot(parentChanged)
	function syncWithParent(previous:Element) {
		if (previous != null) {
			left.position -= previous.left.position;
			top.position -= previous.top.position;
		}
		if (parent != null) {
			left.position += parent.left.position;
			top.position += parent.top.position;
		}
	}

	@:slot(childAdded)
	function __childAdded__(child:Element) {
		function insert(child:Element) {
			for (c in visibleChildren)
				if (c.index > child.index) {
					visibleChildren.insert(c.index, child);
					return;
				}
			visibleChildren.push(child);
		}
		if (child.visible)
			insert(child);

		var slot = v -> {
			if (!v && child.visible)
				insert(child);
			else if (v && !child.visible)
				visibleChildren.remove(child);
		};
		child.onVisibleChanged(slot);
		child.onParentChanged(_ -> child.offVisibleChanged(slot));
	}

	@:slot(childRemoved)
	function __childRemoved__(child:Element) {
		if (child.visible)
			visibleChildren.remove(child);
	}

	function set__x(value:Float) {
		if (value != _x) {
			final prev = _x;
			_x = value;
			xChanged(prev);
		}
		return _x;
	}

	function set__y(value:Float) {
		if (value != _y) {
			final prev = _y;
			_y = value;
			yChanged(prev);
		}
		return _y;
	}

	function set__width(value:Float) {
		if (value != _width) {
			final prev = _width;
			_width = value;
			widthChanged(prev);
		}
		return _width;
	}

	function set__height(value:Float) {
		if (value != _height) {
			final prev = _height;
			_height = value;
			heightChanged(prev);
		}
		return _height;
	}

	function get_x():Float {
		return _x;
	}

	function set_x(value:Float):Float {
		if (!left.isBinded) {
			final d = value - x;
			left.position += d;
			if (!right.isBinded)
				right.position += d;
			for (c in children)
				c.left.position += d;
		}
		return x;
	}

	function get_y():Float {
		return _y;
	}

	function set_y(value:Float) {
		if (!top.isBinded) {
			final d = value - y;
			top.position += d;
			if (!bottom.isBinded)
				bottom.position += d;
			for (c in children)
				c.top.position += d;
		}
		return y;
	}

	function get_width():Float {
		return _width;
	}

	function set_width(value:Float) {
		if (!right.isBinded)
			right.position = left.position + value;
		return width;
	}

	function get_height():Float {
		return _height;
	}

	function set_height(value:Float) {
		if (!bottom.isBinded)
			bottom.position = top.position + value;
		return height;
	}

	function get_anchors():Anchors {
		return this;
	}

	function set_padding(value:Float) {
		left.padding = value;
		top.padding = value;
		right.padding = value;
		bottom.padding = value;
		return value;
	}

	function get_bounds():Bounds {
		return new Bounds(x, y, x + width, y + height);
	}

	function set_bounds(value:Bounds):Bounds {
		x = value.left;
		y = value.top;
		width = value.right - value.left;
		height = value.bottom - value.top;
		return value;
	}

	function get_contentBounds():Bounds {
		return new Bounds(x + left.padding, y + top.padding, x + width - right.padding, y + height - bottom.padding);
	}

	function set_contentBounds(value:Bounds):Bounds {
		x = value.left - left.padding;
		y = value.top - top.padding;
		width = value.right - value.left + right.padding;
		height = value.bottom - value.top + bottom.padding;
		return value;
	}

	function get_rect():Rect {
		return new Rect(x, y, width, height);
	}

	function set_rect(value:Rect):Rect {
		x = value.x;
		y = value.y;
		width = value.width;
		height = value.height;
		return value;
	}

	function get_contentRect():Rect {
		return new Rect(x + left.padding, y + top.padding, width - left.padding - right.padding, height - top.padding - bottom.padding);
	}

	function set_contentRect(value:Rect):Rect {
		x = value.x - left.padding;
		y = value.y - top.padding;
		width = value.width + right.padding;
		height = value.height + bottom.padding;
		return value;
	}
}
