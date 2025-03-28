package s2d;

import se.Log;
import se.Texture;
import se.math.VectorMath;
import s2d.Anchors;
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

	var scene:WindowScene;
	var anchoring:Int = 0;

	public var left:AnchorLineH = new AnchorLineH_S();
	public var hCenter:AnchorLineH = new AnchorLineH_S();
	public var right:AnchorLineH = new AnchorLineH_E();
	public var top:AnchorLineV = new AnchorLineV_S();
	public var vCenter:AnchorLineV = new AnchorLineV_S();
	public var bottom:AnchorLineV = new AnchorLineV_E();
	public var anchors:ElementAnchors;
	public var padding(never, set):Float;

	public var layout:ElementLayout = new ElementLayout();
	public var opacity:Float = 1.0;

	@:isVar var _absX(default, set):Float = 0.0;
	@:isVar var _absY(default, set):Float = 0.0;

	public var absX(get, set):Float;
	public var absY(get, set):Float;

	@:isVar public var x(default, set):Float = 0.0;
	@:isVar public var y(default, set):Float = 0.0;
	@:isVar public var width(default, set):Float = 0.0;
	@:isVar public var height(default, set):Float = 0.0;

	@:signal.private function xChanged(x:Float):Void;

	@:signal.private function yChanged(x:Float):Void;

	@:signal.private function widthChanged(x:Float):Void;

	@:signal.private function heightChanged(x:Float):Void;

	public var bounds(get, set):Bounds;
	public var contentBounds(get, set):Bounds;
	public var rect(get, set):Rect;
	public var contentRect(get, set):Rect;

	public function new() @:privateAccess {
		anchors = new ElementAnchors(this);

		super();
		if (parent == null) {
			scene = WindowScene.current;
			scene.elements.push(this);
		} else
			scene = parent.scene;
	}

	override function __childAdded__(child:Element) {
		child.absX += absX;
		child.absY += absY;
		super.__childAdded__(child);
	}

	override function __childRemoved__(child:Element) {
		child.absX -= absX;
		child.absY -= absY;
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
		return bounds.contains(mapToGlobal(x, y));
	}

	function render(target:Texture) {
		final ctx = target.ctx2D;
		ctx.style.pushOpacity(opacity);
		ctx.transform = globalTransform;
		for (c in vChildren)
			c.render(target);
		ctx.style.popOpacity();
	}

	var _x:Float = 0.0;
	var _y:Float = 0.0;
	var _width:Float = 0.0;
	var _height:Float = 0.0;

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
			geometryChanged();
			--anchoring;
		} else
			Log.warning("Anchor binding loop detected!");
	}

	@:slot(left.positionChanged)
	function syncLeft(p:Float) @:privateAccess {
		if (!(right.isBinded && hCenter.isBinded))
			anchor(() -> {
				final d = left.position - p;
				absX += d;
				if (!right.isBinded && !hCenter.isBinded) {
					hCenter.adjust(d);
					right.adjust(d);
				} else if (right.isBinded && !hCenter.isBinded) {
					width -= d;
					hCenter.adjust(d * 0.5);
				} else if (!right.isBinded && hCenter.isBinded) {
					final d2 = d * 2;
					width -= d2;
					right.adjust(d2);
				}
			});
	}

	@:slot(hCenter.positionChanged)
	function syncHCenter(p:Float) @:privateAccess {
		if (!(left.isBinded && right.isBinded))
			anchor(() -> {
				final d = hCenter.position - p;
				if (!left.isBinded && !right.isBinded) {
					absX += d;
					left.adjust(d);
					right.adjust(d);
				} else if (left.isBinded && !right.isBinded) {
					final d2 = d * 2;
					width += d2;
					right.adjust(d2);
				} else if (!left.isBinded && right.isBinded) {
					final d2 = d * 2;
					absX += d2;
					width -= d2;
					left.adjust(d2);
				}
			});
	}

	@:slot(right.positionChanged)
	function syncRight(p:Float) @:privateAccess {
		if (!(left.isBinded && hCenter.isBinded))
			anchor(() -> {
				final d = right.position - p;
				if (!left.isBinded && !hCenter.isBinded) {
					absX += d;
					left.adjust(d);
					hCenter.adjust(d);
				} else if (left.isBinded && !hCenter.isBinded) {
					width += d;
					hCenter.adjust(d * 0.5);
				} else if (!left.isBinded && hCenter.isBinded) {
					absX -= d;
					width += d * 2;
					left.adjust(-d);
				}
			});
	}

	@:slot(top.positionChanged)
	function syncTop(p:Float) @:privateAccess {
		if (!(bottom.isBinded && vCenter.isBinded))
			anchor(() -> {
				final d = top.position - p;
				absY += d;
				if (!bottom.isBinded && !vCenter.isBinded) {
					vCenter.adjust(d);
					bottom.adjust(d);
				} else if (bottom.isBinded && !vCenter.isBinded) {
					height -= d;
					vCenter.adjust(d * 0.5);
				} else if (!bottom.isBinded && vCenter.isBinded) {
					final d2 = d * 2;
					height -= d2;
					bottom.adjust(d2);
				}
			});
	}

	@:slot(vCenter.positionChanged)
	function syncVCenter(p:Float) @:privateAccess {
		if (!(top.isBinded && bottom.isBinded))
			anchor(() -> {
				final d = vCenter.position - p;
				if (!top.isBinded && !bottom.isBinded) {
					absY += d;
					top.adjust(d);
					bottom.adjust(d);
				} else if (top.isBinded && !bottom.isBinded) {
					final d2 = d * 2;
					height += d2;
					bottom.adjust(d2);
				} else if (!top.isBinded && bottom.isBinded) {
					final d2 = d * 2;
					absY += d2;
					height -= d2;
					top.adjust(d2);
				}
			});
	}

	@:slot(bottom.positionChanged)
	function syncBottom(p:Float) @:privateAccess {
		if (!(top.isBinded && vCenter.isBinded))
			anchor(() -> {
				final d = bottom.position - p;
				if (!top.isBinded && !vCenter.isBinded) {
					absY += d;
					top.adjust(d);
					vCenter.adjust(d);
				} else if (top.isBinded && !vCenter.isBinded) {
					height += d;
					vCenter.adjust(d * 0.5);
				} else if (!top.isBinded && vCenter.isBinded) {
					absY -= d;
					height += d * 2;
					top.adjust(-d);
				}
			});
	}

	function set__absX(value:Float):Float {
		final d = value - _absX;
		_absX = value;
		for (c in children)
			c._absX += d;
		return _absX;
	}

	function set__absY(value:Float):Float {
		final d = value - _absY;
		_absY = value;
		for (c in children)
			c._absY += d;
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

	function set_x(value:Float):Float @:privateAccess {
		if (!(left.isBinded || right.isBinded || hCenter.isBinded) || anchoring > 0) {
			final d = value - x;
			x = value;
			_absX += d;
			if (anchoring == 0)
				anchor(() -> {
					left.adjust(d);
					hCenter.adjust(d);
					right.adjust(d);
				});
		}
		return x;
	}

	function set_y(value:Float):Float @:privateAccess {
		if (!(top.isBinded || bottom.isBinded || vCenter.isBinded) || anchoring > 0) {
			final d = value - y;
			y = value;
			_absY += d;
			if (anchoring == 0)
				anchor(() -> {
					top.adjust(d);
					vCenter.adjust(d);
					bottom.adjust(d);
				});
		}
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
						hCenter.adjust(d * 0.5);
						right.adjust(d);
					} else if (!left.isBinded && !hCenter.isBinded && right.isBinded) {
						x -= d;
						left.adjust(-d);
						hCenter.adjust(-d * 0.5);
					} else if (!left.isBinded && hCenter.isBinded && !right.isBinded) {
						x -= d * 0.5;
						left.adjust(-d * 0.5);
						right.adjust(-d);
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
						vCenter.adjust(d * 0.5);
						bottom.adjust(d);
					} else if (!top.isBinded && !vCenter.isBinded && bottom.isBinded) {
						y -= d;
						top.adjust(-d);
						vCenter.adjust(-d * 0.5);
					} else if (!top.isBinded && vCenter.isBinded && !bottom.isBinded) {
						y -= d * 0.5;
						top.adjust(-d * 0.5);
						bottom.adjust(-d);
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
