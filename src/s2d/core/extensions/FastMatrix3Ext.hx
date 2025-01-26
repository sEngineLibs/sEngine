package s2d.core.extensions;

import kha.FastFloat;
import kha.math.FastVector2;
import kha.math.FastMatrix3;

using s2d.core.extensions.FastMatrix3Ext;

class FastMatrix3Ext {
	public static function orthogonalProjection(left:Float, right:Float, bottom:Float, top:Float):FastMatrix3 {
		var tx = -(right + left) / (right - left);
		var ty = -(top + bottom) / (top - bottom);

		return new FastMatrix3(2 / (right - left), 0, tx, 0, 2.0 / (top - bottom), ty, 0, 0, 1);
	}

	public static function lookAt(eye:FastVector2, at:FastVector2, up:FastVector2):FastMatrix3 {
		var zaxis = at.sub(eye).normalized();
		return new FastMatrix3(-zaxis.y, zaxis.x, zaxis.y * eye.x - zaxis.x * eye.y, -zaxis.x, -zaxis.y, zaxis.x * eye.x + zaxis.y * eye.y, 0, 0, 1);
	}

	public static function getTranslationX(m:FastMatrix3):FastFloat {
		return m._20;
	}

	public static function getTranslationY(m:FastMatrix3):FastFloat {
		return m._21;
	}

	public static function setTranslationX(m:FastMatrix3, value:FastFloat):Void {
		m._20 = value;
	}

	public static function setTranslationY(m:FastMatrix3, value:FastFloat):Void {
		m._21 = value;
	}

	public static function getTranslation(m:FastMatrix3):FastVector2 {
		return {
			x: m.getTranslationX(),
			y: m.getTranslationY()
		}
	}

	public static function setTranslation(m:FastMatrix3, value:FastVector2):Void {
		m.setTranslationX(value.x);
		m.setTranslationY(value.y);
	}

	public static function getScaleX(m:FastMatrix3):FastFloat {
		return Math.sqrt(m._00 * m._00 + m._10 * m._10);
	}

	public static function setScaleX(m:FastMatrix3, value:FastFloat):Void {
		var xt = new FastVector2(m._00, m._10).normalized();
		m._00 = xt.x * value;
		m._10 = xt.y * value;
	}

	public static function getScaleY(m:FastMatrix3):FastFloat {
		return Math.sqrt(m._01 * m._01 + m._11 * m._11);
	}

	public static function setScaleY(m:FastMatrix3, value:FastFloat):Void {
		var yt = new FastVector2(m._01, m._11).normalized();
		m._01 = yt.x * value;
		m._11 = yt.y * value;
	}

	public static function getScale(m:FastMatrix3):FastVector2 {
		return {
			x: m.getScaleX(),
			y: m.getScaleY()
		}
	}

	public static function setScale(m:FastMatrix3, value:FastVector2):Void {
		m.setScaleX(value.x);
		m.setScaleY(value.y);
	}

	public static function getRotation(m:FastMatrix3):FastFloat {
		return Math.atan2(m._10, m._00);
	}

	public static function setRotation(m:FastMatrix3, value:FastFloat):Void {
		var sx = m.getScaleX();
		var sy = m.getScaleY();
		var c = Math.cos(value);
		var s = Math.sin(value);
		m._00 = c * sx;
		m._10 = s * sx;
		m._01 = -s * sy;
		m._11 = c * sy;
	}
}
