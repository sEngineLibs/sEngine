package s2d.objects;

import kha.FastFloat;
// s2d
import s2d.math.SMath;
import s2d.math.Vec2;
import s2d.math.Mat3;

class Object {
	@:isVar public var parent(default, null):Object = null;
	@:isVar public var children(default, null):Array<Object> = [];

	var _model(get, never):Mat3;

	public var model:Mat3 = Mat3.identity();
	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;
	public var scaleX(get, set):FastFloat;
	public var scaleY(get, set):FastFloat;
	public var rotation(get, set):FastFloat;

	public inline function new() {}

	public inline function setParent(value:Object):Void {
		if (parent == value || value == null)
			return;
		value.addChild(this);
		parent = value;
	}

	public inline function addChild(value:Object):Void {
		if (value == null || value == this || children.contains(value))
			return;
		value.setParent(this);
	}

	overload extern public inline function moveG(x:FastFloat, y:FastFloat) {
		this.x += x;
		this.y += y;
	}

	overload extern public inline function moveG(value:FastFloat) {
		moveG(value, value);
	}

	overload extern public inline function moveG(value:Vec2) {
		moveG(value.x, value.y);
	}

	overload extern public inline function moveToG(x:FastFloat, y:FastFloat) {
		this.x = x;
		this.y = y;
	}

	overload extern public inline function moveToG(value:Vec2) {
		moveToG(value.x, value.y);
	}

	overload extern public inline function moveToG(value:FastFloat) {
		moveToG(value, value);
	}

	overload extern public inline function scaleG(x:FastFloat, y:FastFloat) {
		this.scaleX *= x;
		this.scaleY *= y;
	}

	overload extern public inline function scaleG(value:Vec2) {
		scaleG(value.x, value.y);
	}

	overload extern public inline function scaleG(value:FastFloat) {
		scaleG(value, value);
	}

	overload extern public inline function scaleToG(x:FastFloat, y:FastFloat) {
		this.scaleX = x;
		this.scaleY = y;
	}

	overload extern public inline function scaleToG(value:Vec2) {
		scaleToG(value.x, value.y);
	}

	overload extern public inline function scaleToG(value:FastFloat) {
		scaleToG(value, value);
	}

	public inline function rotateG(angle:FastFloat) {
		this.rotation += angle;
	}

	public inline function rotateToG(angle:FastFloat) {
		this.rotation = angle;
	}

	overload extern public inline function moveL(x:FastFloat, y:FastFloat) {
		model = model * Mat3.translation(x, y);
	}

	overload extern public inline function moveL(value:FastFloat) {
		moveL(value, value);
	}

	overload extern public inline function moveL(value:Vec2) {
		moveL(value.x, value.y);
	}

	overload extern public inline function moveToL(x:FastFloat, y:FastFloat) {
		model = model * Mat3.translation(x - this.x, y - this.y);
	}

	overload extern public inline function moveToL(value:Vec2) {
		moveToL(value.x, value.y);
	}

	overload extern public inline function moveToL(value:FastFloat) {
		moveToL(value, value);
	}

	overload extern public inline function scaleL(x:FastFloat, y:FastFloat) {
		model = model * Mat3.scale(x, y);
	}

	overload extern public inline function scaleL(value:Vec2) {
		scaleL(value.x, value.y);
	}

	overload extern public inline function scaleL(value:FastFloat) {
		scaleL(value, value);
	}

	overload extern public inline function scaleToL(x:FastFloat, y:FastFloat) {
		model = model * Mat3.scale(x / scaleX, y / scaleY);
	}

	overload extern public inline function scaleToL(value:Vec2) {
		scaleToL(value.x, value.y);
	}

	overload extern public inline function scaleToL(value:FastFloat) {
		scaleToL(value, value);
	}

	public inline function rotateL(angle:FastFloat) {
		model = model * Mat3.rotation(angle);
	}

	public inline function rotateToL(angle:FastFloat) {
		model = model * Mat3.rotation(angle - rotation);
	}

	inline function get__model():Mat3 {
		return parent == null ? model : parent._model * model;
	}

	inline function get_x():FastFloat {
		return model._20;
	}

	inline function set_x(value:FastFloat):FastFloat {
		model._20 = value;
		return value;
	}

	inline function get_y():FastFloat {
		return model._21;
	}

	inline function set_y(value:FastFloat):FastFloat {
		model._21 = value;
		return value;
	}

	inline function get_scaleX():FastFloat {
		return sqrt(pow(model._00, 2.0) + pow(model._10, 2.0));
	}

	inline function set_scaleX(value:FastFloat):FastFloat {
		var xt = normalize(vec2(model._00, model._10));
		model._00 = xt.x * value;
		model._10 = xt.y * value;
		return value;
	}

	inline function get_scaleY():FastFloat {
		return sqrt(pow(model._01, 2.0) + pow(model._11, 2.0));
	}

	inline function set_scaleY(value:FastFloat):FastFloat {
		var yt = normalize(vec2(model._01, model._11));
		model._01 = yt.x * value;
		model._11 = yt.y * value;
		return value;
	}

	inline function get_rotation():FastFloat {
		return atan2(model._10, model._00);
	}

	inline function set_rotation(value:FastFloat):FastFloat {
		var sx = scaleX;
		var sy = scaleY;
		var c = cos(value);
		var s = sin(value);
		model._00 = c * sx;
		model._10 = s * sx;
		model._01 = -s * sy;
		model._11 = c * sy;
		return value;
	}
}
