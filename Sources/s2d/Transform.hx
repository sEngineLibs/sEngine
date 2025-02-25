package s2d;

import kha.math.FastMatrix3 as KhaMat3;
import se.math.Vec2;
import se.math.Mat3;
import se.math.VectorMath;

@:forward.new
@:forward(_00, _10, _20, _01, _11, _21, _02, _12, _22)
extern abstract Transform(Mat3) from Mat3 to Mat3 {
	public var global(get, set):TransformGlobal;
	public var local(get, set):TransformLocal;

	@:from
	public static inline function fromKhaMat3(value:KhaMat3):Transform {
		return (value : Mat3);
	}

	@:to
	public inline function toKhaMat3():KhaMat3 {
		return (this : KhaMat3);
	}

	private inline function get_global() {
		return this;
	}

	private inline function set_global(value:TransformGlobal):TransformGlobal {
		return this = value;
	}

	private inline function get_local() {
		return this;
	}

	private inline function set_local(value:TransformLocal):TransformLocal {
		return this = value;
	}
}

extern abstract TransformGlobal(Mat3) from Mat3 to Mat3 {
	public var translationX(get, set):Float;
	public var translationY(get, set):Float;
	public var translation(get, set):Vec2;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var globalScale(get, set):Vec2;
	public var rotation(get, set):Float;

	overload public inline function translate(x:Float, y:Float) {
		translationX += x;
		translationY += y;
	}

	overload public inline function translate(value:Vec2) {
		translate(value.x, value.y);
	}

	overload public inline function translate(value:Float) {
		translate(value, value);
	}

	overload public inline function translateTo(x:Float, y:Float) {
		translationX = x;
		translationY = y;
	}

	overload public inline function translateTo(value:Vec2) {
		translateTo(value.x, value.y);
	}

	overload public inline function translateTo(value:Float) {
		translateTo(value, value);
	}

	overload public inline function scale(x:Float, y:Float) {
		scaleX *= x;
		scaleY *= y;
	}

	overload public inline function scale(value:Vec2) {
		scale(value.x, value.y);
	}

	overload public inline function scale(value:Float) {
		scale(value, value);
	}

	overload public inline function scaleTo(x:Float, y:Float) {
		scaleX = x;
		scaleY = y;
	}

	overload public inline function scaleTo(value:Vec2) {
		scaleTo(value.x, value.y);
	}

	overload public inline function scaleTo(value:Float) {
		scaleTo(value, value);
	}

	public inline function rotate(value:Float) {
		rotation += value;
	}

	public inline function rotateTo(value:Float) {
		rotation = value;
	}

	private inline function get_translationX():Float {
		return this._20;
	}

	private inline function set_translationX(value:Float):Float {
		this._20 = value;
		return value;
	}

	private inline function get_translationY():Float {
		return this._21;
	}

	private inline function set_translationY(value:Float):Float {
		this._21 = value;
		return value;
	}

	private inline function get_translation():Vec2 {
		return vec2(translationX, translationY);
	}

	private inline function set_translation(value:Vec2):Vec2 {
		translationX = value.x;
		translationY = value.y;
		return value;
	}

	private inline function get_scaleX():Float {
		return sqrt(this._00 * this._00 + this._10 * this._10);
	}

	private inline function set_scaleX(value:Float):Float {
		var xt = normalize(vec2(this._00, this._10)) * value;
		this._00 = xt.x;
		this._10 = xt.y;
		return value;
	}

	private inline function get_scaleY():Float {
		return sqrt(this._01 * this._01 + this._11 * this._11);
	}

	private inline function set_scaleY(value:Float):Float {
		var yt = normalize(vec2(this._01, this._11)) * value;
		this._01 = yt.x;
		this._11 = yt.y;
		return value;
	}

	private inline function get_globalScale():Vec2 {
		return vec2(scaleX, scaleY);
	}

	private inline function set_globalScale(value:Vec2):Vec2 {
		scaleX = value.x;
		scaleY = value.y;
		return value;
	}

	private inline function get_rotation():Float {
		return atan2(this._10, this._00);
	}

	private inline function set_rotation(value:Float):Float {
		var sx = scaleX;
		var sy = scaleY;
		var c = cos(value);
		var s = sin(value);
		this._00 = c * sx;
		this._10 = s * sx;
		this._01 = -s * sy;
		this._11 = c * sy;
		return value;
	}
}

extern abstract TransformLocal(Mat3) from Mat3 to Mat3 {
	overload public inline function translate(x:Float, y:Float) {
		this *= Mat3.translation(x, y);
	}

	overload public inline function translate(value:Vec2) {
		translate(value.x, value.y);
	}

	overload public inline function translate(value:Float) {
		translate(value, value);
	}

	overload public inline function scale(x:Float, y:Float) {
		this *= Mat3.scale(x, y);
	}

	overload public inline function scale(value:Vec2) {
		scale(value.x, value.y);
	}

	overload public inline function scale(value:Float) {
		scale(value, value);
	}

	public inline function rotate(value:Float) {
		this *= Mat3.rotation(value);
	}
}
