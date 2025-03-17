package se.extensions;

import se.math.Vec3;
import se.math.Mat4;
import se.math.VectorMath;

using se.extensions.Mat4Ext;

class Mat4Ext {
	public static inline function pushTranslation(m:Mat4, value:Vec3):Void {
		m.setTranslation(m.getTranslation() + value);
	}

	public static inline function pushScale(m:Mat4, value:Vec3):Void {
		m.setScale(m.getScale() * value);
	}

	public static inline function pushRotation(m:Mat4, yaw:Float, pitch:Float, roll:Float):Void {
		m *= Mat4.rotation(yaw, pitch, roll);
	}

	public static inline function translateG(m:Mat4, value:Vec3) {
		pushTranslation(m, value);
	}

	public static inline function translateToG(m:Mat4, value:Vec3) {
		m.setTranslation(value);
	}

	public static inline function scaleG(m:Mat4, value:Vec3) {
		pushScale(m, value);
	}

	public static inline function scaleToG(m:Mat4, value:Vec3) {
		m.setScale(value);
	}

	public static inline function rotateG(m:Mat4, yaw:Float, pitch:Float, roll:Float) {
		pushRotation(m, yaw, pitch, roll);
	}

	public static inline function rotateToG(m:Mat4, yaw:Float, pitch:Float, roll:Float) {
		m.setRotation(yaw, pitch, roll);
	}

	public static inline function getTranslation(m:Mat4):Vec3 {
		return vec3(m._30, m._31, m._32);
	}

	public static inline function setTranslation(m:Mat4, value:Vec3):Vec3 {
		m._30 = value.x;
		m._31 = value.y;
		m._32 = value.z;
		return value;
	}

	public static inline function getScale(m:Mat4):Vec3 {
		return vec3(sqrt(m._00 * m._00 + m._10 * m._10 + m._20 * m._20), sqrt(m._01 * m._01 + m._11 * m._11 + m._21 * m._21),
			sqrt(m._02 * m._02 + m._12 * m._12 + m._22 * m._22));
	}

	public static inline function setScale(m:Mat4, value:Vec3):Vec3 {
		var sx = normalize(vec3(m._00, m._10, m._20)) * value.x;
		var sy = normalize(vec3(m._01, m._11, m._21)) * value.y;
		var sz = normalize(vec3(m._02, m._12, m._22)) * value.z;
		m._00 = sx.x;
		m._10 = sx.y;
		m._20 = sx.z;
		m._01 = sy.x;
		m._11 = sy.y;
		m._21 = sy.z;
		m._02 = sz.x;
		m._12 = sz.y;
		m._22 = sz.z;
		return value;
	}

	public static inline function getRotation(m:Mat4):Vec3 {
		return vec3(atan2(m._21, m._22), atan2(-m._20, sqrt(m._21 * m._21 + m._22 * m._22)), atan2(m._10, m._00));
	}

	public static inline function setRotation(m:Mat4, yaw:Float, pitch:Float, roll:Float):Void {
		m *= Mat4.rotation(yaw, pitch, roll);
	}
}
