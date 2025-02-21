package se.s3d;

import kha.math.FastMatrix4 as KhaMat4;
import se.math.Vec3;
import se.math.Mat4;
import se.math.VectorMath;

using se.extensions.Mat4Ext;

@:nullSafety
@:forward.new
@:forward(_00, _10, _20, _30, _01, _11, _21, _31, _02, _12, _22, _32, _03, _13, _23, _33)
abstract Transform(Mat4) from Mat4 to Mat4 {
	public var translationX(get, set):Float;
	public var translationY(get, set):Float;
	public var translationZ(get, set):Float;
	public var translation(get, set):Vec3;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var scaleZ(get, set):Float;
	public var scale(get, set):Vec3;
	public var rotation(get, set):Vec3;

	@:from
	public static inline function fromKhaMat4(value:KhaMat4):Transform {
		return (value : Mat4);
	}

	@:to
	public inline function toKhaMat4():KhaMat4 {
		return (this : KhaMat4);
	}

	public inline function pushTranslation(value:Vec3):Void {
		this.pushTranslation(value);
	}

	public inline function pushScale(value:Vec3):Void {
		this.pushScale(value);
	}

	public inline function pushRotation(yaw:Float, pitch:Float, roll:Float):Void {
		this.pushRotation(yaw, pitch, roll);
	}

	overload extern public inline function translateG(value:Vec3) {
		this.translateG(value);
	}

	overload extern public inline function translateToG(value:Vec3) {
		this.translateToG(value);
	}

	overload extern public inline function scaleG(value:Vec3) {
		this.scaleG(value);
	}

	overload extern public inline function scaleToG(value:Vec3) {
		this.scaleToG(value);
	}

	public function rotateG(value:Float) {
		this.rotateG(value, value, value);
	}

	public function rotateToG(value:Float) {
		this.rotateToG(value, value, value);
	}

	// overload extern public inline function translateL(x:Float, y:Float, z:Float) {
	// 	this.translateL(x, y, z);
	// }
	// overload extern public inline function translateToL(x:Float, y:Float, z:Float) {
	// 	this.translateToL(x, y, z);
	// }
	// overload extern public inline function scaleL(x:Float, y:Float, z:Float) {
	// 	this.scaleL(x, y, z);
	// }
	// overload extern public inline function scaleToL(x:Float, y:Float, z:Float) {
	// 	this.scaleToL(x, y, z);
	// }
	// public inline function rotateL(x:Float, y:Float, z:Float) {
	// 	this.rotateL(x, y, z);
	// }
	// public inline function rotateToL(x:Float, y:Float, z:Float) {
	// 	this.rotateToL(x, y, z);
	// }

	overload extern public inline function translateG(x:Float, y:Float, z:Float) {
		this.translateG({x: x, y: y});
	}

	overload extern public inline function translateG(value:Float) {
		this.translateG({x: value, y: value});
	}

	overload extern public inline function translateToG(x:Float, y:Float, z:Float) {
		this.translateToG({x: x, y: y});
	}

	overload extern public inline function translateToG(value:Float) {
		this.translateToG({x: value, y: value});
	}

	overload extern public inline function scaleG(x:Float, y:Float, z:Float) {
		this.scaleG({x: x, y: y});
	}

	overload extern public inline function scaleG(value:Float) {
		this.scaleG({x: value, y: value});
	}

	overload extern public inline function scaleToG(x:Float, y:Float, z:Float) {
		this.scaleToG({x: x, y: y});
	}

	overload extern public inline function scaleToG(value:Float) {
		this.scaleToG({x: value, y: value});
	}

	// overload extern public inline function translateL(value:Vec3) {
	// 	this.translateL(value.x, value.y, value.z);
	// }
	// overload extern public inline function translateL(value:Float) {
	// 	this.translateL(value, value, value);
	// }
	// overload extern public inline function translateToL(value:Vec3) {
	// 	this.translateToL(value.x, value.y, value.z);
	// }
	// overload extern public inline function translateToL(value:Float) {
	// 	this.translateToL(value, value, value);
	// }
	// overload extern public inline function scaleL(value:Vec3) {
	// 	this.scaleL(value.x, value.y, value.z);
	// }
	// overload extern public inline function scaleL(value:Float) {
	// 	this.scaleL(value, value, value);
	// }
	// overload extern public inline function scaleToL(value:Vec3) {
	// 	this.scaleToL(value.x, value.y, value.z);
	// }
	// overload extern public inline function scaleToL(value:Float) {
	// 	this.scaleToL(value, value, value);
	// }

	inline function get_translationX():Float {
		return this.getTranslation().x;
	}

	inline function set_translationX(value:Float):Float {
		var t = this.getTranslation();
		this.setTranslation(vec3(value, t.y, t.z));
		return value;
	}

	inline function get_translationY():Float {
		return this.getTranslation().y;
	}

	inline function set_translationY(value:Float):Float {
		var t = this.getTranslation();
		this.setTranslation(vec3(t.x, value, t.z));
		return value;
	}

	inline function get_translationZ():Float {
		return this.getTranslation().z;
	}

	inline function set_translationZ(value:Float):Float {
		var t = this.getTranslation();
		this.setTranslation(vec3(t.x, t.y, value));
		return value;
	}

	inline function get_translation():Vec3 {
		return this.getTranslation();
	}

	inline function set_translation(value:Vec3):Vec3 {
		this.setTranslation(value);
		return value;
	}

	inline function get_scaleX():Float {
		return this.getScale().x;
	}

	inline function set_scaleX(value:Float):Float {
		var s = this.getScale();
		this.setScale(vec3(value, s.y, s.z));
		return value;
	}

	inline function get_scaleY():Float {
		return this.getScale().y;
	}

	inline function set_scaleY(value:Float):Float {
		var s = this.getScale();
		this.setScale(vec3(s.x, value, s.z));
		return value;
	}

	inline function get_scaleZ():Float {
		return this.getScale().z;
	}

	inline function set_scaleZ(value:Float):Float {
		var s = this.getScale();
		this.setScale(vec3(s.x, s.y, value));
		return value;
	}

	inline function get_scale():Vec3 {
		return this.getScale();
	}

	inline function set_scale(value:Vec3):Vec3 {
		this.setScale(value);
		return value;
	}

	inline function get_rotation():Vec3 {
		return this.getRotation();
	}

	inline function set_rotation(value:Vec3):Vec3 {
		this.setRotation(value.x, value.y, value.z);
		return value;
	}
}
