package sui.elements;

import kha.math.Vector2;
// sui
import score.utils.MathUtils;
import sui.positioning.Anchors;
import sui.elements.batches.ElementBatch;

@:autoBuild(score.macro.SMacro.build())
class Element {
	public function new(?scene:SUI) {
		anchors = new Anchors(this);
		if (scene != null)
			scene.add(this);
	}

	// anchors
	public var anchors:Anchors;
	@readonly public var left:AnchorLine = {};
	@readonly public var top:AnchorLine = {};
	@readonly public var right:AnchorLine = {};
	@readonly public var bottom:AnchorLine = {};
	@readonly public var horizontalCenter:AnchorLine = {};
	@readonly public var verticalCenter:AnchorLine = {};

	// positioning
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z:Float;
	public var centerX(get, set):Float;
	public var centerY(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;
	@:isVar public var minWidth(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxWidth(default, set):Float = Math.POSITIVE_INFINITY;
	@:isVar public var minHeight(default, set):Float = Math.NEGATIVE_INFINITY;
	@:isVar public var maxHeight(default, set):Float = Math.POSITIVE_INFINITY;

	inline function get_x():Float {
		return left.position;
	}

	inline function set_x(value:Float):Float {
		var d = value - x;
		left.position = value;
		horizontalCenter.position += d / 2;
		right.position += d;
		return value;
	}

	inline function get_y():Float {
		return top.position;
	}

	inline function set_y(value:Float):Float {
		var d = value - y;
		top.position = value;
		verticalCenter.position += d / 2;
		bottom.position += d;
		return value;
	}

	inline function get_centerX():Float {
		return horizontalCenter.position;
	}

	inline function set_centerX(value:Float):Float {
		var d = value - centerX;
		left.position += d;
		horizontalCenter.position = value;
		right.position += d;
		return value;
	}

	inline function get_centerY():Float {
		return verticalCenter.position;
	}

	inline function set_centerY(value:Float):Float {
		var d = value - centerY;
		top.position += d;
		verticalCenter.position = value;
		bottom.position += d;
		return value;
	}

	inline function get_width():Float {
		return right.position - x;
	}

	inline function set_width(value:Float):Float {
		value = MathUtils.clamp(value, minWidth, maxWidth);
		horizontalCenter.position = x + value / 2;
		right.position = x + value;
		return value;
	}

	inline function get_height():Float {
		return bottom.position - y;
	}

	inline function set_height(value:Float):Float {
		value = MathUtils.clamp(value, minHeight, maxHeight);
		verticalCenter.position = y + value / 2;
		bottom.position = y + value;
		return value;
	}

	inline function set_minWidth(value:Float):Float {
		minWidth = value;
		width = width;
		return value;
	}

	inline function set_maxWidth(value:Float):Float {
		maxWidth = value;
		width = width;
		return value;
	}

	inline function set_minHeight(value:Float):Float {
		minHeight = value;
		height = height;
		return value;
	}

	inline function set_maxHeight(value:Float):Float {
		maxHeight = value;
		height = height;
		return value;
	}

	// transformation
	public var origin:Vector2 = {};
	@:isVar public var scaleX(default, set):Float = 1;
	@:isVar public var scaleY(default, set):Float = 1;
	@:isVar public var rotation(default, set):Float = 0;
	@:isVar public var translationX(default, set):Float = 0;
	@:isVar public var translationY(default, set):Float = 0;

	function set_scaleX(value:Float):Float {
		scaleX = value;
		return value;
	}

	function set_scaleY(value:Float):Float {
		scaleY = value;
		return value;
	}

	function set_rotation(value:Float):Float {
		rotation = value;
		return value;
	}

	function set_translationX(value:Float):Float {
		translationX = value;
		return value;
	}

	function set_translationY(value:Float):Float {
		translationY = value;
		return value;
	}

	public inline function scale(?x:Float = 1, ?y:Float = 1) {
		scaleX *= x;
		scaleY *= y;
	}

	public inline function rotate(angle:Float = 0) {
		rotation += angle;
	}

	public inline function translate(?x:Float = 0, ?y:Float = 0) {
		translationX += x;
		translationY += y;
	}

	public var parent:Element = null;
	public var children:Array<Element> = [];
	public var enabled:Bool = true;

	public var finalEnabled(get, never):Bool;

	function get_finalEnabled():Bool {
		return parent == null ? enabled : parent.finalEnabled && enabled;
	}

	public var batch:ElementBatch;
	public var instanceID:Int;
	public var batchType(get, never):Class<ElementBatch>;

	function get_batchType():Class<ElementBatch> {
		return null;
	}

	public function resize(w:Int, h:Int) {
		width = w;
		height = h;
	}

	public inline function resizeTree(w:Int, h:Int) {
		resize(w, h);
		for (child in children)
			child.resizeTree(w, h);
	}

	public function addChild(child:Element) {
		children.push(child);
		child.parent = this;
	}

	public function removeChild(child:Element) {
		var index = children.indexOf(child);
		if (index != -1) {
			children.splice(index, 1);
			child.parent = null;
		}
	}

	public function removeChildren() {
		for (child in children)
			child.parent = null;

		children = [];
	}

	public function setParent(parent:Element) {
		parent.addChild(this);
	}

	public function removeParent() {
		parent.removeChild(this);
	}

	public inline function mapFromGlobal(point:Vector2):Vector2 {
		return {x: point.x - x, y: point.y - y};
	}

	public inline function mapToGlobal(point:Vector2):Vector2 {
		return {x: point.x + x, y: point.y + y};
	}

	public static inline function mapFromElement(element:Element, point:Vector2):Vector2 {
		return element.mapToGlobal(point);
	}

	public static inline function mapToElement(element:Element, point:Vector2):Vector2 {
		return element.mapFromGlobal(point);
	}
}
