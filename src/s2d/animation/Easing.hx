package s2d.animation;

import kha.FastFloat;

abstract Easing((FastFloat) -> FastFloat) from (FastFloat) -> FastFloat to (FastFloat) -> FastFloat {
	public static var Linear = (t:FastFloat) -> t;
	public static var Bezier = (t:FastFloat) -> t * t * (3 - 2 * t);
	// quad
	public static var InQuad = (t:FastFloat) -> t * t;
	public static var OutQuad = (t:FastFloat) -> (2 - t) * t;
	public static var InOutQuad = (t:FastFloat) -> t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
	public static var OutInQuad = (t:FastFloat) -> t < 0.5 ? 0.5 * (2 - 2 * t) * (2 * t) : 0.5 * (1 - (2 - 2 * t) * (2 - 2 * t) + 1);
	// cubic
	public static var InCubic = (t:FastFloat) -> t * t * t;
	public static var OutCubic = (t:FastFloat) -> (t - 1) * (t - 1) * (t - 1) + 1;
	public static var InOutCubic = (t:FastFloat) -> t < 0.5 ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1;
	public static var OutInCubic = (t:FastFloat) -> t < 0.5 ? 0.5 * ((2 * t - 1) * (2 * t - 1) * (2 * t - 1) + 1) : 0.5 * ((2 * t - 2) * (2 * t - 2) * (2 * t
		- 2)
		+ 2);
	// quart
	public static var InQuart = (t:FastFloat) -> t * t * t * t;
	public static var OutQuart = (t:FastFloat) -> 1 - (t - 1) * (t - 1) * (t - 1) * (t - 1);
	public static var InOutQuart = (t:FastFloat) -> t < 0.5 ? 8 * t * t * t * t : 1 - 8 * (t - 1) * (t - 1) * (t - 1) * (t - 1);
	public static var OutInQuart = (t:FastFloat) -> t < 0.5 ? 0.5 * (1 - (2 * t - 1) * (2 * t - 1) * (2 * t - 1) * (2 * t - 1) + 1) : 0.5 * (1
		- (2 * t - 2) * (2 * t - 2) * (2 * t - 2) * (2 * t - 2) + 1);
	// quint
	public static var InQuint = (t:FastFloat) -> t * t * t * t * t;
	public static var OutQuint = (t:FastFloat) -> (t - 1) * (t - 1) * (t - 1) * (t - 1) * (t - 1) + 1;
	public static var InOutQuint = (t:FastFloat) -> t < 0.5 ? 16 * t * t * t * t * t : 16 * (t - 1) * (t - 1) * (t - 1) * (t - 1) * (t - 1) + 1;
	public static var OutInQuint = (t:FastFloat) -> t < 0.5 ? 0.5 * ((2 * t - 1) * (2 * t - 1) * (2 * t - 1) * (2 * t - 1) * (2 * t - 1)
		+ 1) : 0.5 * ((2 * t - 2) * (2 * t - 2) * (2 * t - 2) * (2 * t - 2) * (2 * t - 2) + 2);
	// sine
	public static var InSine = (t:FastFloat) -> 1 - Math.cos(t * (Math.PI / 2));
	public static var OutSine = (t:FastFloat) -> Math.sin(t * (Math.PI / 2));
	public static var InOutSine = (t:FastFloat) -> -0.5 * (Math.cos(Math.PI * t) - 1);
	public static var OutInSine = (t:FastFloat) -> t < 0.5 ? 0.5 * (Math.sin(2 * t * Math.PI / 2)) : 0.5 * (-Math.cos(2 * (t - 0.5) * Math.PI / 2) + 2);
	// expo
	public static var InExpo = (t:FastFloat) -> Math.pow(2, 10 * (t - 1));
	public static var OutExpo = (t:FastFloat) -> 1 - Math.pow(2, -10 * t);
	public static var InOutExpo = (t:FastFloat) -> t < 0.5 ? 0.5 * Math.pow(2, (20 * t) - 10) : 0.5 * (2 - Math.pow(2, 10 - 20 * t));
	public static var OutInExpo = (t:FastFloat) -> t < 0.5 ? 0.5 * (1 - Math.pow(2, -20 * t)) : 0.5 * (Math.pow(2, 20 * (t - 0.5)) + 1);
	// circ
	public static var InCirc = (t:FastFloat) -> 1 - Math.sqrt(1 - t * t);
	public static var OutCirc = (t:FastFloat) -> Math.sqrt(1 - (t - 1) * (t - 1));
	public static var InOutCirc = (t:FastFloat) -> t < 0.5 ? 0.5 * (1 - Math.sqrt(1 - 4 * t * t)) : 0.5 * (Math.sqrt(1 - 4 * (t - 1) * (t - 1)) + 1);
	public static var OutInCirc = (t:FastFloat) -> t < 0.5 ? 0.5 * Math.sqrt(1 - 4 * (t - 0.5) * (t - 0.5)) : 0.5 * (-Math.sqrt(1 - 4 * (t - 1) * (t - 1)) + 2);
	// elastic
	public static var InElastic = (t:FastFloat) -> t == 0 ? 0 : (t == 1 ? 1 : -Math.pow(2, 10 * t - 10) * Math.sin((t * 10 - 10.75) * (2 * Math.PI) / 4.5));
	public static var OutElastic = (t:FastFloat) -> t == 0 ? 0 : (t == 1 ? 1 : Math.pow(2, -10 * t) * Math.sin((t * 10 - 0.75) * (2 * Math.PI) / 4.5) + 1);
	public static var InOutElastic = (t:FastFloat) -> t == 0 ? 0 : (t == 1 ? 1 : t < 0.5 ?
		-Math.pow(2,
			20 * t - 10) * Math.sin((20 * t - 11.125) * (2 * Math.PI) / 4.5) / 2 : (Math.pow(2,
			-20 * t + 10) * Math.sin((20 * t - 11.125) * (2 * Math.PI) / 4.5)) / 2
			+ 1);
	public static var OutInElastic = (t:FastFloat) -> t < 0.5 ? 0.5 * (Math.pow(2, -20 * t) * Math.sin((20 * t - 1.125) * (2 * Math.PI) / 4.5)
		+ 1) : 0.5 * (-Math.pow(2, 20 * (t - 0.5) - 10) * Math.sin((20 * (t - 0.5) - 1.125) * (2 * Math.PI) / 4.5) + 2);
	// back
	public static var InBack = (t:FastFloat) -> 2.70158 * t * t * t - 1.70158 * t * t;
	public static var OutBack = (t:FastFloat) -> 1 + 2.70158 * Math.pow(t - 1, 3) + 1.70158 * Math.pow(t - 1, 2);
	public static var InOutBack = (t:FastFloat) -> t < 0.5 ? (2 * t * 2 * t * ((2.5949095 + 1) * 2 * t - 2.5949095)) / 2 : (Math.pow(2 * t - 2,
		2) * ((2.5949095 + 1) * (t * 2 - 2) + 2.5949095)
		+ 2) / 2;
	public static var OutInBack = (t:FastFloat) -> t < 0.5 ? 0.5 * (Math.pow(2 * t - 1, 2) * ((2.5949095 + 1) * (t * 2 - 1) + 2.5949095)
		+ 1) : 0.5 * (1 + Math.pow(2 * t - 2, 2) * ((2.5949095 + 1) * (t * 2 - 2) + 2.5949095) + 1);
	// bounce
	public static var InBounce = (t:FastFloat) -> 1 - Easing.OutBounce(1 - t);
	public static var OutBounce = (t:FastFloat) -> {
		if (t < 1 / 2.75)
			return 7.5625 * t * t;
		else if (t < 2 / 2.75)
			return 7.5625 * (t - 0.545455) * (t - 0.545455) + 0.75;
		else if (t < 2.5 / 2.75)
			return 7.5625 * (t - 0.818182) * (t - 0.818182) + 0.9375;
		else
			return 7.5625 * (t - 0.954545) * (t - 0.954545) + 0.984375;
	}
	public static var InOutBounce = (t:FastFloat) -> t < 0.5 ? (1 - Easing.OutBounce(1 - 2 * t)) / 2 : (1 + Easing.OutBounce(2 * t - 1)) / 2;
	public static var OutInBounce = (t:FastFloat) -> t < 0.5 ? 0.5 * Easing.OutBounce(2 * t) : 0.5 * (1 - Easing.OutBounce(2 - 2 * t) + 1);
}
