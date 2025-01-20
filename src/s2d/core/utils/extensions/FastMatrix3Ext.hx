package s2d.core.utils.extensions;

import kha.math.FastVector2;
import kha.math.FastMatrix3;

class FastMatrix3Ext {
	public static inline function orthogonalProjection(left:Float, right:Float, bottom:Float, top:Float):FastMatrix3 {
		var tx = -(right + left) / (right - left);
		var ty = -(top + bottom) / (top - bottom);

		return new FastMatrix3(2 / (right - left), 0, tx, 0, 2.0 / (top - bottom), ty, 0, 0, 1);
	}

	public static inline function lookAt(eye:FastVector2, at:FastVector2, up:FastVector2):FastMatrix3 {
		var zaxis = at.sub(eye).normalized();
		return new FastMatrix3(-zaxis.y, zaxis.x, zaxis.y * eye.x - zaxis.x * eye.y, -zaxis.x, -zaxis.y, zaxis.x * eye.x + zaxis.y * eye.y, 0, 0, 1);
	}

	/**
	 * Projects a point onto a line
	 * @param point The point to be projected
	 * @param normal Normal of the line the point will be projected onto
	 * @param linePoint Any point lying on the line the point will be projected onto
	 * @return Returns a listener
	 */
	public static function project(point:FastVector2, normal:FastVector2, linePoint:FastVector2):FastMatrix3 {
		final n = normal.normalized();
		final d = n.x * linePoint.x + n.y * linePoint.y;
		final p = point;
		return new FastMatrix3(n.x * p.x + d, n.y * p.x, -p.x * d, n.x * p.y, n.y * p.y + d, -p.y * d, n.x, n.y, -(p.x * n.x + p.y * n.y));
	}
}
