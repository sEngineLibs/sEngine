package s2d.ui.elements;

import kha.Canvas;
// s2d
import s2d.Color;
import s2d.math.Vec2;
import s2d.math.Vec4;
import s2d.math.VectorMath;
import s2d.geometry.Rect;
import s2d.geometry.Bounds;
import s2d.geometry.Position;
import s2d.core.S2DObject;
import s2d.ui.positioning.Anchors;

@:allow(s2d.ui.UIScene)
class UIElement extends S2DObject<UIElement> {
	var scene:UIScene;
	var finalOpacity(get, never):Float;

	public var focused:Bool = false;
	public var visible:Bool = true;
	public var color:Color = white;
	public var opacity:Float = 1.0;
	public var enabled:Bool = true;
	public var clip:Bool = false;
	public var layout:Layout = {};
	public var childrenRect(get, never):Rect;
	public var childrenBounds(get, never):Bounds;
	public var layer:UILayer = new UILayer();

	// anchors
	public var anchors:Anchors = new Anchors();
	public var left:AnchorLine = {};
	public var top:AnchorLine = {};
	public var right:AnchorLine = {};
	public var bottom:AnchorLine = {};
	@:isVar public var padding(default, set):Float = 0.0;

	// positioning
	var _x:Float = 0.0;
	var _y:Float = 0.0;

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;
	public var availableWidth(get, never):Float;
	public var availableHeight(get, never):Float;
	@:isVar public var minWidth(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxWidth(default, set):Float = Math.POSITIVE_INFINITY;
	@:isVar public var minHeight(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxHeight(default, set):Float = Math.POSITIVE_INFINITY;

	public var rect(get, set):Rect;
	public var bounds(get, set):Bounds;

	public function new(?scene:UIScene) {
		super();
		if (scene != null)
			this.scene = scene;
		else
			this.scene = UIScene.current;
		this.scene.addBaseElement(this);
	}

	overload extern public static inline function mapToElement(element:UIElement, x:Float, y:Float):Position {
		return element.mapFromGlobal(x, y);
	}

	overload extern public static inline function mapToElement(element:UIElement, p:Position):Position {
		return element.mapFromGlobal(p);
	}

	overload extern public static inline function mapFromElement(element:UIElement, x:Float, y:Float):Position {
		return element.mapToGlobal(x, y);
	}

	overload extern public static inline function mapFromElement(element:UIElement, p:Position):Position {
		return element.mapToGlobal(p);
	}

	public function setPadding(value:Float):Void {
		padding = value;
	}

	overload extern public inline function setPosition(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}

	overload extern public inline function setPosition(value:Vec2):Void {
		setPosition(value.x, value.y);
	}

	overload extern public inline function setSize(width:Float, height:Float) {
		this.width = width;
		this.height = height;
	}

	overload extern public inline function setSize(value:Vec2) {
		setSize(value.x, value.y);
	}

	public function setRect(value:Rect):Void {
		setPosition(rect.position);
		setSize(rect.size);
	}

	public function setBounds(value:Bounds):Void {
		setRect(value.toRect());
	}

	overload extern public inline function mapFromGlobal(p:Position):Position {
		return finalModel * p;
	}

	overload extern public inline function mapFromGlobal(x:Float, y:Float):Position {
		return mapFromGlobal(vec2(x, y));
	}

	overload extern public inline function mapToGlobal(p:Position):Position {
		return inverse(finalModel) * p;
	}

	overload extern public inline function mapToGlobal(x:Float, y:Float):Position {
		return mapToGlobal(vec2(x, y));
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
		final g2 = target.g2;

		if (!layer.enabled) {
			g2.color = color;
			g2.opacity = finalOpacity;
			g2.transformation = finalModel;
			renderTree(target);
		} else {
			g2.end();
			final _g2 = layer.texture.g2;
			final sr = layer.sourceRect;
			// to layer texture
			_g2.begin();
			_g2.color = color;
			_g2.opacity = finalOpacity;
			_g2.transformation = finalModel;
			if (sr != null)
				_g2.scissor(sr.x, sr.y, sr.width, sr.height);
			renderTree(layer.texture);
			_g2.disableScissor();
			_g2.end();
			// to target
			g2.begin(false);
			if (layer.effect != null)
				@:privateAccess layer.effect.apply(layer.texture, target);
			else
				g2.drawScaledImage(layer.texture, 0, 0, target.width, target.height);
			g2.end();
		}

		#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
		g2.color = White;
		g2.opacity = 0.75;
		g2.transformation = finalModel;
		g2.drawRect(x, y, width, height, 2.0);
		#end
	}

	function renderTree(target:Canvas) {
		draw(target);
		for (child in children) {
			child.updateBounds();
			if (child.visible)
				child.render(target);
		}
	}

	function draw(target:Canvas) {}

	function updateBounds() {
		// position
		if (anchors.left != null)
			left.position = anchors.left.position + anchors.left.padding + anchors.leftMargin;
		else if (parent != null)
			left.position = _x + parent.left.position + parent.left.padding;

		if (anchors.top != null)
			top.position = anchors.top.position + anchors.top.padding + anchors.topMargin;
		else if (parent != null)
			top.position = _y + parent.top.position + parent.top.padding;

		// size
		if (anchors.right != null)
			right.position = anchors.right.position - anchors.right.padding - anchors.rightMargin;

		if (anchors.bottom != null)
			bottom.position = anchors.bottom.position - anchors.bottom.padding - anchors.bottomMargin;
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
			if (element.finalZ >= finalZ) {
				parent.children.insert(i, this);
				break;
			}
			++i;
		}
	}

	function onTransformationChanged() {}

	function get_rect():Rect {
		return new Rect(x, y, width, height);
	}

	function set_rect(value:Rect):Rect {
		setRect(value);
		return value;
	}

	function get_bounds():Bounds {
		return rect.toBounds();
	}

	function set_bounds(value:Bounds):Bounds {
		setBounds(value);
		return value;
	}

	function get_childrenBounds():Vec4 {
		var b = bounds;
		for (child in children) {
			b.left = Math.min(b.left, child.left.position);
			b.top = Math.min(b.top, child.top.position);
			b.right = Math.max(b.right, child.right.position);
			b.bottom = Math.max(b.bottom, child.bottom.position);
		}
		return b;
	}

	function get_childrenRect():Vec4 {
		return childrenBounds.toRect();
	}

	function get_finalOpacity():Float {
		return parent == null ? opacity : parent.finalOpacity * opacity;
	}

	function get_x():Float {
		return left.position;
	}

	function set_x(value:Float):Float {
		_x = value;
		right.position += value - x;
		left.position = value;
		return value;
	}

	function get_y():Float {
		return top.position;
	}

	function set_y(value:Float):Float {
		_y = value;
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

	function get_availableWidth():Float {
		return width - left.padding - right.padding;
	}

	function get_availableHeight():Float {
		return height - top.padding - bottom.padding;
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
