package s2d.core.utils.extensions;

import kha.math.Vector2;
import kha.math.FastMatrix3;

class FastMatrix3Ext {
	public static inline function orthogonalProjection(left:Float, right:Float, bottom:Float, top:Float):FastMatrix3 {
		var tx = -(right + left) / (right - left);
		var ty = -(top + bottom) / (top - bottom);

		return new FastMatrix3(2 / (right - left), 0, tx, 0, 2.0 / (top - bottom), ty, 0, 0, 1);
	}

	public static inline function lookAt(eye:Vector2, at:Vector2, up:Vector2):FastMatrix3 {
		var zaxis = at.sub(eye).normalized();
		return new FastMatrix3(-zaxis.y, zaxis.x, zaxis.y * eye.x - zaxis.x * eye.y, -zaxis.x, -zaxis.y, zaxis.x * eye.x + zaxis.y * eye.y, 0, 0, 1);
	}
}
