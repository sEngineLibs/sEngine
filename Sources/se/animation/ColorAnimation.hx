package se.animation;

import se.math.VectorMath.mix;

class ColorAnimation extends Animation<Color> {
	private inline function update(t:Float):Color {
		return mix(from.RGBA, to.RGBA, t);
	}
}
