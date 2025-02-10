package se.extensions;

import se.math.Vec2;
import se.math.Mat3;
import se.math.VectorMath;

using se.extensions.Mat3Ext;

class Mat3Ext {
	public static inline function pushTranslation(m:Mat3, value:Vec2):Void {
		m.setTranslation(m.getTranslation() + value);
	}

	public static inline function pushScale(m:Mat3, value:Vec2):Void {
		m.setScale(m.getScale() * value);
	}

	public static inline function pushRotation(m:Mat3, value:Float):Void {
		m.setRotation(m.getRotation() + value);
	}

	public static inline function translateG(m:Mat3, value:Vec2) {
		pushTranslation(m, value);
	}

	public static inline function translateToG(m:Mat3, value:Vec2) {
		m.setTranslation(value);
	}

	public static inline function scaleG(m:Mat3, value:Vec2) {
		pushScale(m, value);
	}

	public static inline function scaleToG(m:Mat3, value:Vec2) {
		m.setScale(value);
	}

	public static inline function rotateG(m:Mat3, value:Float) {
		pushRotation(m, value);
	}

	public static inline function rotateToG(m:Mat3, value:Float) {
		m.setRotation(value);
	}

	public static inline function translateL(m:Mat3, x:Float, y:Float) {
		m *= Mat3.translation(x, y);
	}

	public static inline function translateToL(m:Mat3, x:Float, y:Float) {
		m = Mat3.translation(x - m.getTranslationX(), y - m.getTranslationY());
	}

	public static inline function scaleL(m:Mat3, x:Float, y:Float) {
		m *= Mat3.scale(x, y);
	}

	public static inline function scaleToL(m:Mat3, x:Float, y:Float) {
		m *= Mat3.scale(x / m.getScaleX(), y / m.getScaleY());
	}

	public static inline function rotateL(m:Mat3, value:Float) {
		m *= Mat3.rotation(value);
	}

	public static inline function rotateToL(m:Mat3, value:Float) {
		m *= Mat3.rotation(value - m.getRotation());
	}

	public static inline function getTranslationX(m:Mat3):Float {
		return m._20;
	}

	public static inline function setTranslationX(m:Mat3, value:Float):Float {
		m._20 = value;
		return value;
	}

	public static inline function getTranslationY(m:Mat3):Float {
		return m._21;
	}

	public static inline function setTranslationY(m:Mat3, value:Float):Float {
		m._21 = value;
		return value;
	}

	public static inline function getTranslation(m:Mat3):Vec2 {
		return vec2(m.getTranslationX(), m.getTranslationY());
	}

	public static inline function setTranslation(m:Mat3, value:Vec2):Vec2 {
		m.setTranslationX(value.x);
		m.setTranslationX(value.y);
		return value;
	}

	public static inline function getScaleX(m:Mat3):Float {
		return sqrt(m._00 * m._00 + m._10 * m._10);
	}

	public static inline function setScaleX(m:Mat3, value:Float):Float {
		var xt = normalize(vec2(m._00, m._10)) * value;
		m._00 = xt.x;
		m._10 = xt.y;
		return value;
	}

	public static inline function getScaleY(m:Mat3):Float {
		return sqrt(m._01 * m._01 + m._11 * m._11);
	}

	public static inline function setScaleY(m:Mat3, value:Float):Float {
		var yt = normalize(vec2(m._01, m._11)) * value;
		m._01 = yt.x;
		m._11 = yt.y;
		return value;
	}

	public static inline function getScale(m:Mat3):Vec2 {
		return vec2(m.getScaleX(), m.getScaleY());
	}

	public static inline function setScale(m:Mat3, value:Vec2):Vec2 {
		m.setScaleX(value.x);
		m.setScaleY(value.y);
		return value;
	}

	public static inline function getRotation(m:Mat3):Float {
		return atan2(m._10, m._00);
	}

	public static inline function setRotation(m:Mat3, value:Float):Float {
		var sx = m.getScaleX();
		var sy = m.getScaleY();
		var c = cos(value);
		var s = sin(value);
		m._00 = c * sx;
		m._10 = s * sx;
		m._01 = -s * sy;
		m._11 = c * sy;
		return value;
	}
}
