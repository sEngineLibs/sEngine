package se.animation;

import se.math.VectorMath.mix;
import se.math.VectorMath.Float;

class NumberAnimation extends Animation<Float> {
	inline function update(t:Float):Float {
		return mix(from, to, t);
	}
}
