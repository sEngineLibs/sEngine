package s2d.animation;

import kha.FastFloat;
// s2d
import s2d.core.Time;
import s2d.animation.Actuator;

@:allow(s2d.S2D)
@:allow(s2d.animation.Actuator)
class Action {
	static var actuators:Array<Actuator<Dynamic>> = [];

	public static function tween<T>(source:T, target:T, duration:FastFloat) {
		final actuator = new Actuator<T>(source, target, duration);
		actuator.start = Time.time;
		actuators.push(actuator);
		return actuator;
	}

	static inline function update(time:FastFloat) {
		for (actuator in actuators)
			actuator.advance(time);
	}
}
