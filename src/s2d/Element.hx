package s2d;

import kha.input.KeyCode;
import se.Log;
import se.Texture;
import se.math.Vec2;
import se.math.Mat3;
import se.math.VectorMath;
import se.input.Mouse;
import se.events.MouseEvents;
import s2d.Anchors;
import s2d.FocusPolicy;
import s2d.geometry.Size;
import s2d.geometry.Rect;
import s2d.geometry.Bounds;
import s2d.geometry.Position;

@:allow(s2d.WindowScene)
class Element extends PhysicalObject2D<Element> {
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

	var anchoring:Int = 0;

	@track public var enabled:Bool = false;
	public var containsMouse:Bool = false;
	@track public var focused:Bool = false;
	public var focusPolicy:FocusPolicy = ClickFocus | TabFocus;

	public var left:HorizontalAnchor = new LeftAnchor();
	public var hCenter:HorizontalAnchor = new HCenterAnchor();
	public var right:HorizontalAnchor = new RightAnchor();
	public var top:VerticalAnchor = new TopAnchor();
	public var vCenter:VerticalAnchor = new VCenterAnchor();
	public var bottom:VerticalAnchor = new BottomAnchor();
	public var anchors:ElementAnchors;
	public var padding(never, set):Float;

	public var layout:Layout = new Layout();
	public var opacity:Float = 1.0;

	@:isVar var _absX(default, set):Float = 0.0;
	@:isVar var _absY(default, set):Float = 0.0;

	public var absX(get, set):Float;
	public var absY(get, set):Float;

	// cached values
	var _x:Float = 0.0;
	var _y:Float = 0.0;
	var _width:Float = 0.0;
	var _height:Float = 0.0;

	@:isVar public var x(default, set):Float = 0.0;
	@:isVar public var y(default, set):Float = 0.0;
	@:isVar public var width(default, set):Float = 0.0;
	@:isVar public var height(default, set):Float = 0.0;

	@:signal.private function absXChanged(x:Float):Void;

	@:signal.private function absYChanged(x:Float):Void;

	@:signal.private function xChanged(x:Float):Void;

	@:signal.private function yChanged(x:Float):Void;

	@:signal.private function widthChanged(x:Float):Void;

	@:signal.private function heightChanged(x:Float):Void;

	@:signal function keyboardDown(key:KeyCode);

	@:signal function keyboardUp(key:KeyCode);

	@:signal function keyboardHold(key:KeyCode);

	@:signal function keyboardPressed(char:String);

	@:signal(key) function keyboardKeyDown(key:KeyCode);

	@:signal(key) function keyboardKeyUp(key:KeyCode);

	@:signal(key) function keyboardKeyHold(key:KeyCode);

	@:signal(char) function keyboardCharPressed(char:String);

	@:signal function mouseEntered(x:Float, y:Float);

	@:signal function mouseExited(x:Float, y:Float);

	@:signal function mouseMoved(m:MouseMoveEvent);

	@:signal function mouseScrolled(m:MouseScrollEvent);

	@:signal function mousePressed(m:MouseButtonEvent);

	@:signal function mouseReleased(m:MouseButtonEvent);

	@:signal function mouseHold(m:MouseButtonEvent);

	@:signal function mouseClicked(m:MouseButtonEvent);

	@:signal function mouseDoubleClicked(m:MouseButtonEvent);

	@:signal(button) function mouseButtonPressed(button:MouseButton, m:MouseEvent);

	@:signal(button) function mouseButtonReleased(button:MouseButton, m:MouseEvent);

	@:signal(button) function mouseButtonHold(button:MouseButton, m:MouseEvent);

	@:signal(button) function mouseButtonClicked(button:MouseButton, m:MouseEvent);

	@:signal(button) function mouseButtonDoubleClicked(button:MouseButton, m:MouseEvent);

	public var bounds(get, set):Bounds;
	public var contentBounds(get, set):Bounds;
	public var rect(get, set):Rect;
	public var contentRect(get, set):Rect;

	public function new(name:String = "element") {
		super(name);

		anchors = new ElementAnchors(this);
		left = new LeftAnchor();
		hCenter = new HCenterAnchor();
		right = new RightAnchor();
		top = new TopAnchor();
		vCenter = new VCenterAnchor();
		bottom = new BottomAnchor();

		onKeyboardDown(keyboardKeyDown.emit);
		onKeyboardUp(keyboardKeyUp.emit);
		onKeyboardHold(keyboardKeyHold.emit);
		onKeyboardPressed(keyboardCharPressed.emit);

		onMousePressed(m -> mouseButtonPressed(m.button, m));
		onMouseReleased(m -> mouseButtonReleased(m.button, m));
		onMouseHold(m -> mouseButtonHold(m.button, m));
		onMouseClicked(m -> mouseButtonClicked(m.button, m));
		onMouseDoubleClicked(m -> mouseButtonDoubleClicked(m.button, m));
	}

	override function __childAdded__(child:Element) {
		child._absX = absX + child.x;
		child._absY = absY + child.y;
		super.__childAdded__(child);
	}

	override function __childRemoved__(child:Element) {
		child._absX = absX - child.x;
		child._absY = absY - child.y;
		super.__childRemoved__(child);
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
		var p = mapToGlobal(x, y);
		return left.position <= p.x && p.x <= right.position && top.position <= p.y && p.y <= bottom.position;
	}

	function render(target:Texture) {
		final ctx = target.ctx2D;
		ctx.style.pushOpacity(opacity);
		ctx.transform = globalTransform;
		for (c in vChildren)
			c.render(target);
		ctx.style.popOpacity();
	}

	function geometryChanged() {
		if (_x != x) {
			xChanged(_x);
			_x = x;
		}
		if (_y != y) {
			yChanged(_y);
			_y = y;
		}
		if (_width != width) {
			widthChanged(_width);
			_width = width;
		}
		if (_height != height) {
			heightChanged(_height);
			_height = height;
		}
	}

	function anchor(f:Void->Void) {
		if (++anchoring == 1) {
			f();
			--anchoring;
			geometryChanged();
		} else
			Log.warning("Possible anchor binding loop detected!");
	}

	override function applyTransform(m:Mat3, ?o:Vec2) {
		if (o == null)
			o = vec2(x, y);
		else
			o += vec2(x, y);
		transform *= Mat3.translation(-o.x, -o.y) * m * Mat3.translation(o.x, o.y);
		syncTransform();
	}

	@:slot(left.positionChanged)
	function syncLeft(p:Float) @:privateAccess {
		if (!(right.isBinded && hCenter.isBinded) && anchoring == 0)
			anchor(() -> {
				final d = left.position - p;
				x += d;
				if (!right.isBinded && !hCenter.isBinded) {
					hCenter.position += d;
					right.position += d;
				} else if (right.isBinded && !hCenter.isBinded) {
					width -= d;
					hCenter.position += d * 0.5;
				} else if (!right.isBinded && hCenter.isBinded) {
					final d2 = d * 2;
					width -= d2;
					right.position += d2;
				}
			});
	}

	@:slot(hCenter.positionChanged)
	function syncHCenter(p:Float) @:privateAccess {
		if (!(left.isBinded && right.isBinded) && anchoring == 0)
			anchor(() -> {
				final d = hCenter.position - p;
				if (!left.isBinded && !right.isBinded) {
					x += d;
					left.position += d;
					right.position += d;
				} else if (left.isBinded && !right.isBinded) {
					final d2 = d * 2;
					width += d2;
					right.position += d2;
				} else if (!left.isBinded && right.isBinded) {
					final d2 = d * 2;
					x += d2;
					width -= d2;
					left.position += d2;
				}
			});
	}

	@:slot(right.positionChanged)
	function syncRight(p:Float) @:privateAccess {
		if (!(left.isBinded && hCenter.isBinded) && anchoring == 0)
			anchor(() -> {
				final d = right.position - p;
				if (!left.isBinded && !hCenter.isBinded) {
					x += d;
					left.position += d;
					hCenter.position += d;
				} else if (left.isBinded && !hCenter.isBinded) {
					width += d;
					hCenter.position += d * 0.5;
				} else if (!left.isBinded && hCenter.isBinded) {
					x -= d;
					width += d * 2;
					left.position -= d;
				}
			});
	}

	@:slot(top.positionChanged)
	function syncTop(p:Float) @:privateAccess {
		if (!(bottom.isBinded && vCenter.isBinded) && anchoring == 0)
			anchor(() -> {
				final d = top.position - p;
				y += d;
				if (!bottom.isBinded && !vCenter.isBinded) {
					vCenter.position += d;
					bottom.position += d;
				} else if (bottom.isBinded && !vCenter.isBinded) {
					height -= d;
					vCenter.position += d * 0.5;
				} else if (!bottom.isBinded && vCenter.isBinded) {
					final d2 = d * 2;
					height -= d2;
					bottom.position += d2;
				}
			});
	}

	@:slot(vCenter.positionChanged)
	function syncVCenter(p:Float) @:privateAccess {
		if (!(top.isBinded && bottom.isBinded) && anchoring == 0)
			anchor(() -> {
				final d = vCenter.position - p;
				if (!top.isBinded && !bottom.isBinded) {
					y += d;
					top.position += d;
					bottom.position += d;
				} else if (top.isBinded && !bottom.isBinded) {
					final d2 = d * 2;
					height += d2;
					bottom.position += d2;
				} else if (!top.isBinded && bottom.isBinded) {
					final d2 = d * 2;
					y += d2;
					height -= d2;
					top.position += d2;
				}
			});
	}

	@:slot(bottom.positionChanged)
	function syncBottom(p:Float) @:privateAccess {
		if (!(top.isBinded && vCenter.isBinded) && anchoring == 0)
			anchor(() -> {
				final d = bottom.position - p;
				if (!top.isBinded && !vCenter.isBinded) {
					y += d;
					top.position += d;
					vCenter.position += d;
				} else if (top.isBinded && !vCenter.isBinded) {
					height += d;
					vCenter.position += d * 0.5;
				} else if (!top.isBinded && vCenter.isBinded) {
					y -= d;
					height += d * 2;
					top.position -= d;
				}
			});
	}

	function set__absX(value:Float):Float @:privateAccess {
		if (!(left.isBinded || right.isBinded || hCenter.isBinded) || anchoring > 0) {
			final prev = _absX;
			_absX = value;
			final d = _absX - prev;
			if (anchoring == 0)
				anchor(() -> {
					left.position += d;
					hCenter.position += d;
					right.position += d;
				});
			absXChanged(prev);
			for (c in children)
				c._absX += d;
		}
		return _absX;
	}

	function set__absY(value:Float):Float @:privateAccess {
		if (!(top.isBinded || bottom.isBinded || vCenter.isBinded) || anchoring > 0) {
			final prev = _absY;
			_absY = value;
			final d = _absY - prev;
			if (anchoring == 0)
				anchor(() -> {
					top.position += d;
					vCenter.position += d;
					bottom.position += d;
				});
			absYChanged(prev);
			for (c in children)
				c._absY += d;
		}
		return _absY;
	}

	function get_absX() {
		return _absX;
	}

	function set_absX(value:Float):Float {
		x += value - absX;
		return absX;
	}

	function get_absY() {
		return _absY;
	}

	function set_absY(value:Float):Float {
		y += value - absY;
		return absY;
	}

	function set_x(value:Float):Float {
		_absX += value - x;
		x = absX;
		if (parent != null)
			x -= parent.absX;
		return x;
	}

	function set_y(value:Float):Float {
		_absY += value - y;
		y = absY;
		if (parent != null)
			y -= parent.absY;
		return y;
	}

	function set_width(value:Float):Float @:privateAccess {
		if (!((left.isBinded && right.isBinded) || (left.isBinded && hCenter.isBinded) || (right.isBinded && hCenter.isBinded))
			|| anchoring > 0) {
			final prev = width;
			width = value;
			if (anchoring == 0)
				anchor(() -> {
					final d = width - prev;
					if (!hCenter.isBinded && !right.isBinded) {
						hCenter.position += d * 0.5;
						right.position += d;
					} else if (!left.isBinded && !hCenter.isBinded && right.isBinded) {
						x -= d;
						left.position -= d;
						hCenter.position -= d;
					} else if (!left.isBinded && hCenter.isBinded && !right.isBinded) {
						final d0 = d * 0.5;
						x -= d0;
						left.position -= d0;
						right.position += d0;
					}
				});
		}
		return width;
	}

	function set_height(value:Float):Float @:privateAccess {
		if (!((top.isBinded && bottom.isBinded) || (top.isBinded && vCenter.isBinded) || (bottom.isBinded && vCenter.isBinded))
			|| anchoring > 0) {
			final prev = height;
			height = value;
			if (anchoring == 0)
				anchor(() -> {
					final d = height - prev;
					if (!vCenter.isBinded && !bottom.isBinded) {
						vCenter.position += d * 0.5;
						bottom.position += d;
					} else if (!top.isBinded && !vCenter.isBinded && bottom.isBinded) {
						y -= d;
						top.position -= d;
						vCenter.position -= d;
					} else if (!top.isBinded && vCenter.isBinded && !bottom.isBinded) {
						final d0 = d * 0.5;
						y -= d0;
						top.position -= d0;
						bottom.position += d0;
					}
				});
		}
		return height;
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
