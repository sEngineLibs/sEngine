package s2d.geometry;

import kha.FastFloat;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastMatrix4;

class Transformation {
	public var matrix:FastMatrix4;
	public var translationX(get, set):FastFloat;
	public var translationY(get, set):FastFloat;
	public var translationZ(get, set):FastFloat;
	public var translation(get, set):FastVector3;
	public var scaleX(get, set):FastFloat;
	public var scaleY(get, set):FastFloat;
	public var rotation(get, set):FastFloat;

	public inline function new(?matrix:FastMatrix4) {
		if (matrix == null)
			matrix = FastMatrix4.identity();
		this.matrix = matrix;
	}

	public inline function multmat(m:FastMatrix4) {
		return new Transformation(matrix.multmat(m));
	}

	public inline function translate(x:FastFloat, y:FastFloat, ?z:FastFloat = 0.0):Void {
		matrix._30 += x;
		matrix._31 += y;
		matrix._32 += z;
	}

	public inline function scale(x:FastFloat, y:FastFloat):Void {
		matrix._00 *= x;
		matrix._10 *= x;
		matrix._20 *= x;
		matrix._01 *= y;
		matrix._11 *= y;
		matrix._21 *= y;
	}

	public inline function rotate(angle:FastFloat):Void {
		rotation += angle;
	}

	inline function get_translationX():FastFloat {
		return matrix._30;
	}

	inline function set_translationX(value:FastFloat):FastFloat {
		matrix._30 = value;
		return value;
	}

	inline function get_translationY():FastFloat {
		return matrix._31;
	}

	inline function set_translationY(value:FastFloat):FastFloat {
		matrix._31 = value;
		return value;
	}

	inline function get_translationZ():FastFloat {
		return matrix._32;
	}

	inline function set_translationZ(value:FastFloat):FastFloat {
		matrix._32 = value;
		return value;
	}

	inline function get_translation():FastVector3 {
		return {
			x: translationX,
			y: translationY,
			z: translationZ
		};
	}

	inline function set_translation(value:FastVector3):FastVector3 {
		translationX = value.x;
		translationY = value.y;
		translationZ = value.z;
		return value;
	}

	inline function get_scaleX():FastFloat {
		return Math.sqrt(matrix._00 * matrix._00 + matrix._10 * matrix._10 + matrix._20 * matrix._20);
	}

	inline function set_scaleX(value:FastFloat):FastFloat {
		var sx = scaleX;
		matrix._00 *= value / sx;
		matrix._10 *= value / sx;
		matrix._20 *= value / sx;
		return value;
	}

	inline function get_scaleY():FastFloat {
		return Math.sqrt(matrix._01 * matrix._01 + matrix._11 * matrix._11 + matrix._21 * matrix._21);
	}

	inline function set_scaleY(value:FastFloat):FastFloat {
		var sy = scaleY;
		matrix._01 *= value / sy;
		matrix._11 *= value / sy;
		matrix._21 *= value / sy;
		return value;
	}

	inline function get_scale():FastVector2 {
		return {
			x: scaleX,
			y: scaleY
		};
	}

	inline function set_scale(value:FastVector2):FastVector2 {
		scaleX = value.x;
		scaleY = value.y;
		return value;
	}

	inline function get_rotation():FastFloat {
		return Math.atan2(matrix._10, matrix._00);
	}

	inline function set_rotation(value:FastFloat):FastFloat {
		var angle = value;
		var sx = scaleX;
		var sy = scaleY;
		var ca = Math.cos(angle);
		var cs = Math.sin(angle);

		matrix._00 = ca * sx;
		matrix._10 = cs * sx;
		matrix._01 = -cs * sy;
		matrix._11 = ca * sy;
		return value;
	}
}
