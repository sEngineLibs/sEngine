package s2d.objects;

import s2d.math.Vec2;
import kha.FastFloat;
import s2d.math.Mat3;

class Object {
	@:isVar public var parent(default, null):Object = null;
	@:isVar public var children(default, null):Array<Object> = [];

	var _transformation(get, never):Mat3;

	public var transformation:Mat3 = Mat3.identity();
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

	overload extern public inline function move(x:FastFloat, y:FastFloat) {
		this.x += x;
		this.y += y;
	}

	overload extern public inline function move(value:Vec2) {
		move(value.x, value.y);
	}

	overload extern public inline function moveTo(x:FastFloat, y:FastFloat) {
		this.x = x;
		this.y = y;
	}

	overload extern public inline function moveTo(value:Vec2) {
		moveTo(value.x, value.y);
	}

	overload extern public inline function scale(x:FastFloat, y:FastFloat) {
		this.scaleX *= x;
		this.scaleY *= y;
	}

	overload extern public inline function scale(value:Vec2) {
		scale(value.x, value.y);
	}

	overload extern public inline function scaleTo(x:FastFloat, y:FastFloat) {
		this.scaleX = x;
		this.scaleY = y;
	}

	overload extern public inline function scaleTo(value:Vec2) {
		scaleTo(value.x, value.y);
	}

	public inline function rotate(angle:FastFloat) {
		this.rotation += angle;
	}

	public inline function rotateTo(angle:FastFloat) {
		this.rotation = angle;
	}

	inline function get__transformation():Mat3 {
		return parent == null ? transformation : parent._transformation * transformation;
	}

	inline function get_x():FastFloat {
		return transformation[2][0];
	}

	inline function set_x(value:FastFloat):FastFloat {
		transformation[2][0] = value;
		return value;
	}

	inline function get_y():FastFloat {
		return transformation[2][1];
	}

	inline function set_y(value:FastFloat):FastFloat {
		transformation[2][1] = value;
		return value;
	}

	inline function get_scaleX():FastFloat {
		return transformation[0][0];
	}

	inline function set_scaleX(value:FastFloat):FastFloat {
		transformation[0][0] = value;
		return value;
	}

	inline function get_scaleY():FastFloat {
		return transformation[1][1];
	}

	inline function set_scaleY(value:FastFloat):FastFloat {
		transformation[1][1] = value;
		return value;
	}

	inline function get_rotation():FastFloat {
		return Math.atan2(transformation[1][0], transformation[0][0]);
	}

	inline function set_rotation(value:FastFloat):FastFloat {
		transformation *= Mat3.rotation(value - rotation);
		return value;
	}
}
