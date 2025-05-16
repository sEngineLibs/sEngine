package se.animation;

import se.math.SMath;

class NumberAnimation extends Animation<Float> {
	function update(t:Float):Float {
		return mix(from, to, t);
	}
}
