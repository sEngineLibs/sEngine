package s2d;

import kha.math.FastMatrix3 as KhaMat3;
import se.math.Vec2;
import se.math.Mat3;
import se.math.VectorMath;

using se.extensions.Mat3Ext;

@:nullSafety
@:forward.new
@:forward(_00, _10, _20, _01, _11, _21, _02, _12, _22)
abstract Transform(Mat3) from Mat3 to Mat3 {
	public var translationX(get, set):Float;
	public var translationY(get, set):Float;
	public var translation(get, set):Vec2;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var scale(get, set):Vec2;
	public var rotation(get, set):Float;

	@:from
	public static inline function fromKhaMat3(value:KhaMat3):Transform {
		return (value : Mat3);
	}

	@:to
	public inline function toKhaMat3():KhaMat3 {
		return (this : KhaMat3);
	}

	public inline function pushTranslation(value:Vec2):Void {
		this.pushTranslation(value);
	}

	public inline function pushScale(value:Vec2):Void {
		this.pushScale(value);
	}

	public inline function pushRotation(value:Float):Void {
		this.pushRotation(value);
	}

	overload extern public inline function translateG(value:Vec2) {
		this.translateG(value);
	}

	overload extern public inline function translateToG(value:Vec2) {
		this.translateToG(value);
	}

	overload extern public inline function scaleG(value:Vec2) {
		this.scaleG(value);
	}

	overload extern public inline function scaleToG(value:Vec2) {
		this.scaleToG(value);
	}

	public function rotateG(value:Float) {
		this.rotateG(value);
	}

	public function rotateToG(value:Float) {
		this.rotateToG(value);
	}

	overload extern public inline function translateL(x:Float, y:Float) {
		this.translateL(x, y);
	}

	overload extern public inline function translateToL(x:Float, y:Float) {
		this.translateToL(x, y);
	}

	overload extern public inline function scaleL(x:Float, y:Float) {
		this.scaleL(x, y);
	}

	overload extern public inline function scaleToL(x:Float, y:Float) {
		this.scaleToL(x, y);
	}

	public inline function rotateL(value:Float) {
		this.rotateL(value);
	}

	public inline function rotateToL(value:Float) {
		this.rotateToL(value);
	}

	overload extern public inline function translateG(x:Float, y:Float) {
		this.translateG({x: x, y: y});
	}

	overload extern public inline function translateG(value:Float) {
		this.translateG({x: value, y: value});
	}

	overload extern public inline function translateToG(x:Float, y:Float) {
		this.translateToG({x: x, y: y});
	}

	overload extern public inline function translateToG(value:Float) {
		this.translateToG({x: value, y: value});
	}

	overload extern public inline function scaleG(x:Float, y:Float) {
		this.scaleG({x: x, y: y});
	}

	overload extern public inline function scaleG(value:Float) {
		this.scaleG({x: value, y: value});
	}

	overload extern public inline function scaleToG(x:Float, y:Float) {
		this.scaleToG({x: x, y: y});
	}

	overload extern public inline function scaleToG(value:Float) {
		this.scaleToG({x: value, y: value});
	}

	overload extern public inline function translateL(value:Vec2) {
		this.translateL(value.x, value.y);
	}

	overload extern public inline function translateL(value:Float) {
		this.translateL(value, value);
	}

	overload extern public inline function translateToL(value:Vec2) {
		this.translateToL(value.x, value.y);
	}

	overload extern public inline function translateToL(value:Float) {
		this.translateToL(value, value);
	}

	overload extern public inline function scaleL(value:Vec2) {
		this.scaleL(value.x, value.y);
	}

	overload extern public inline function scaleL(value:Float) {
		this.scaleL(value, value);
	}

	overload extern public inline function scaleToL(value:Vec2) {
		this.scaleToL(value.x, value.y);
	}

	overload extern public inline function scaleToL(value:Float) {
		this.scaleToL(value, value);
	}

	inline function get_translationX():Float {
		return this.getTranslationX();
	}

	inline function set_translationX(value:Float):Float {
		this.setTranslationX(value);
		return value;
	}

	inline function get_translationY():Float {
		return this.getTranslationY();
	}

	inline function set_translationY(value:Float):Float {
		this.setTranslationY(value);
		return value;
	}

	inline function get_translation():Vec2 {
		return this.getTranslation();
	}

	inline function set_translation(value:Vec2):Vec2 {
		this.setTranslation(value);
		return value;
	}

	inline function get_scaleX():Float {
		return this.getScaleX();
	}

	inline function set_scaleX(value:Float):Float {
		this.setScaleX(value);
		return value;
	}

	inline function get_scaleY():Float {
		return this.getScaleY();
	}

	inline function set_scaleY(value:Float):Float {
		this.setScaleY(value);
		return value;
	}

	inline function get_scale():Vec2 {
		return this.getScale();
	}

	inline function set_scale(value:Vec2):Vec2 {
		this.setScale(value);
		return value;
	}

	inline function get_rotation():Float {
		return this.getRotation();
	}

	inline function set_rotation(value:Float):Float {
		this.setRotation(value);
		return value;
	}
}
