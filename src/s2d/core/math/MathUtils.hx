package s2d.core.math;

import kha.FastFloat;

class MathUtils {
	public static function clamp(x:Dynamic, xmin:Dynamic, xmax:Dynamic):Dynamic {
		if (xmin > xmax)
			throw "Invalid clamp range: xmin should be less than or equal to xmax.";
		return x < xmin ? xmin : (x > xmax ? xmax : x);
	}

	public static function repeat(x:Dynamic, xmin:Dynamic, xmax:Dynamic):Dynamic {
		return xmin + x % (xmax - xmin);
	}

	public static function mix(x:Dynamic, y:Dynamic, a:FastFloat):Dynamic {
		return x + a * (y - x);
	}
}
