package s2d.animation;

import kha.FastFloat;
// s2d
import s2d.core.Time;
import s2d.core.utils.MathUtils;

@:allow(s2d.S2D)
class Motion {
	static var actuators:Array<Actuator> = [];

	public static inline function tween(target:Dynamic, properties:Dynamic, duration:FastFloat) {
		final actuator = new Actuator(target, properties, duration);
		actuators.push(actuator);
		return actuator;
	}

	static inline function update() {
		var rm:Array<Actuator> = [];

		for (actuator in actuators) {
			var t = (Time.time - actuator.start) / actuator.duration;
			if (t < 1.0) {
				t = MathUtils.clamp(t, 0.0, 1.0);
				t = actuator.easing(t);
				for (prop in Reflect.fields(actuator.properties)) {
					final s = Reflect.field(actuator.source, prop);
					final e = Reflect.field(actuator.properties, prop);
					final v = lerp(s, e, t);
					Reflect.setField(actuator.target, prop, v);
				}
			} else {
				for (prop in Reflect.fields(actuator.properties)) {
					final v = Reflect.field(actuator.properties, prop);
					Reflect.setField(actuator.target, prop, v);
				}
				rm.push(actuator);
			}
		}

		for (a in rm)
			actuators.remove(a);
	}

	static inline function lerp(v0:FastFloat, v1:FastFloat, t:FastFloat):FastFloat {
		return v0 + t * (v1 - v0);
	}
}
