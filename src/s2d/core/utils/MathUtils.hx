package s2d.core.utils;

class MathUtils {
	public static inline function clamp(x:Float, xmin:Float, xmax:Float):Float {
		return Math.min(Math.max(x, xmin), xmax);
	}

	public static inline function iclamp(x:Int, xmin:Int, xmax:Int):Int {
		return Std.int(clamp(x, xmin, xmax));
	}

	public static inline function repeat(x:Float, xmin:Float, xmax:Float):Float {
		return xmin + x % (xmax - xmin);
	}

	public static inline function irepeat(x:Int, xmin:Int, xmax:Int):Int {
		return xmin + x % (xmax - xmin);
	}
}
