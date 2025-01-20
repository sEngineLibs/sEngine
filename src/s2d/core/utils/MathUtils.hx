package s2d.core.utils;

overload extern inline function clamp(x:Float, min:Float, max:Float):Float {
	return Math.max(Math.min(x, max), min);
}

overload extern inline function clamp(x:Int, min:Int, max:Int):Int {
	return x > min ? (x < max ? x : max) : min;
}
