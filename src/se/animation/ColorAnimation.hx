package se.animation;

import se.math.SMath;

class ColorAnimation extends Animation<Color> {
	function update(t:Float):Color {
		return mix(from.RGBA, to.RGBA, t);
	}
}
