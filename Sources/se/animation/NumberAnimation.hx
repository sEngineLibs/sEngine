package se.animation;

import se.math.VectorMath.mix;
import se.math.VectorMath.Float;

class NumberAnimation extends Animation<Float> {
	function update(t:Float) {
		return mix(from, to, t);
	}
}
