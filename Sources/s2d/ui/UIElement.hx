package s2d.ui;

import se.Color;
import se.Texture;
import se.math.Vec2;
import se.math.Vec4;
import se.math.Mat3;
import se.math.VectorMath;
import s2d.ui.Anchors;
import s2d.geometry.Size;
import s2d.geometry.Rect;
import s2d.geometry.Bounds;
import s2d.geometry.Position;

@:allow(s2d.ui.UIScene)
class UIElement extends PhysicalObject<UIElement> {
	overload extern public static inline function mapToElement(element:UIElement, x:Float, y:Float):Position {
		return element.mapFromGlobal(x, y);
	}

	overload extern public static inline function mapToElement(element:UIElement, p:Position):Position {
		return element.mapFromGlobal(p.x, p.y);
	}

	overload extern public static inline function mapFromElement(element:UIElement, x:Float, y:Float):Position {
		return element.mapToGlobal(x, y);
	}

	overload extern public static inline function mapFromElement(element:UIElement, p:Position):Position {
		return element.mapToGlobal(p.x, p.y);
	}

	var finalOpacity(get, never):Float;

	public var layout:Layout = new Layout();
	public var layer:UILayer = new UILayer();

	public var left:AnchorLine = new AnchorLine(1.0);
	public var top:AnchorLine = new AnchorLine(1.0);
	public var right:AnchorLine = new AnchorLine(-1.0);
	public var bottom:AnchorLine = new AnchorLine(-1.0);
	public var anchors(get, never):Anchors;
	public var padding(never, set):Float;

	@:track public var visible:Bool = true;
	@:track public var focused:Bool = false;
	@:track public var enabled:Bool = true;
	@:track public var opacity:Float = 1.0;
	@:track public var color:Color = White;
	@:track public var clip:Bool = false;

	@:track public var x(get, set):Float;
	@:track public var y(get, set):Float;
	@:track public var width(get, set):Float;
	@:track public var height(get, set):Float;
	@:track public var minWidth:Float = Math.NEGATIVE_INFINITY;
	@:track public var maxWidth:Float = Math.POSITIVE_INFINITY;
	@:track public var minHeight:Float = Math.NEGATIVE_INFINITY;
	@:track public var maxHeight:Float = Math.POSITIVE_INFINITY;

	public var rect(get, set):Rect;
	public var bounds(get, set):Bounds;
	public var contentRect(get, set):Rect;
	public var contentBounds(get, set):Bounds;
	public var childrenRect(get, never):Rect;
	public var childrenBounds(get, never):Bounds;

	public function new(?parent:UIElement) {
		super(parent);

		onMinWidthChanged(_ -> width = width);
		onMaxWidthChanged(_ -> width = width);
		onMinHeightChanged(_ -> height = height);
		onMaxHeightChanged(_ -> height = height);
	}

	public function setPadding(value:Float):Void {
		padding = value;
	}

	overload extern public inline function mapFromGlobal(p:Position):Position {
		return (_transform : Mat3) * p;
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

	function render(target:Texture) {
		final ctx = target.ctx2D;

		if (layer.enabled) {
			final _ctx = layer.texture.ctx2D;
			final sr = layer.sourceRect;

			ctx.end();
			// to layer texture
			_ctx.begin();
			if (sr != null)
				_ctx.scissor(sr.x, sr.y, sr.width, sr.height);
			renderTree(layer.texture);
			_ctx.disableScissor();
			_ctx.end();
			// to target
			ctx.begin();
			if (layer.effect != null)
				layer.effect.apply(layer.texture, target);
			else
				ctx.drawScaledImage(layer.texture, 0, 0, target.width, target.height);
		} else
			renderTree(target);
	}

	function renderTree(target:Texture) {
		final ctx = target.ctx2D;

		syncTransform();
		ctx.transform = _transform;
		ctx.style.color = color;
		ctx.style.opacity = finalOpacity;
		draw(target);

		for (child in children)
			if (child.visible)
				child.render(target);
	}

	function draw(target:Texture) {}

	inline function get_anchors():Anchors {
		return this;
	}

	inline function get_x():Float {
		return left.position;
	}

	inline function set_x(value:Float):Float {
		if (!left.isBinded) {
			final d = value - x;
			left.position = value;
			if (anchors.right == null)
				right.position += d;
			for (c in children)
				c.x += d;
		}
		return value;
	}

	inline function get_y():Float {
		return top.position;
	}

	inline function set_y(value:Float):Float {
		if (!top.isBinded) {
			final d = value - y;
			top.position = value;
			if (anchors.bottom == null)
				bottom.position += d;
			for (c in children)
				c.y += d;
		}
		return value;
	}

	inline function get_width():Float {
		return right.position - x;
	}

	inline function set_width(value:Float):Float {
		if (!right.isBinded)
			right.position = x + clamp(value, minWidth, maxWidth);
		return value;
	}

	inline function get_height():Float {
		return bottom.position - y;
	}

	inline function set_height(value:Float):Float {
		if (!bottom.isBinded)
			bottom.position = y + clamp(value, minHeight, maxHeight);
		return value;
	}

	inline function get_rect():Rect {
		return new Rect(x, y, width, height);
	}

	inline function set_rect(value:Rect):Rect {
		setRect(value);
		return value;
	}

	inline function get_bounds():Bounds {
		return rect.toBounds();
	}

	inline function set_bounds(value:Bounds):Bounds {
		setBounds(value);
		return value;
	}

	inline function get_contentRect():Rect {
		return new Rect(x + left.padding, y + top.padding, width - left.padding - right.padding, height - top.padding - bottom.padding);
	}

	inline function set_contentRect(value:Rect):Rect {
		setContentRect(value);
		return value;
	}

	inline function get_contentBounds():Bounds {
		return contentRect.toBounds();
	}

	inline function set_contentBounds(value:Bounds):Bounds {
		setContentBounds(value);
		return value;
	}

	inline function get_childrenBounds():Vec4 {
		var b = bounds;
		for (child in children) {
			b.left = Math.min(b.left, child.left.position);
			b.top = Math.min(b.top, child.top.position);
			b.right = Math.max(b.right, child.right.position);
			b.bottom = Math.max(b.bottom, child.bottom.position);
		}
		return b;
	}

	inline function get_childrenRect():Vec4 {
		return childrenBounds.toRect();
	}

	inline function set_padding(value:Float) {
		left.padding = value;
		top.padding = value;
		right.padding = value;
		bottom.padding = value;
		return value;
	}

	inline function get_finalOpacity():Float {
		return parent == null ? opacity : parent.finalOpacity * opacity;
	}
}
