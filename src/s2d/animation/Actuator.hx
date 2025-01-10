package s2d.animation;

import kha.FastFloat;
// s2d
import s2d.core.Time;

@:allow(s2d.animation.Motion)
class Actuator {
	var source:Dynamic;
	var target:Dynamic;
	var properties:Dynamic;
	var start:Float;
	var duration:Float;
	var easing:(FastFloat) -> FastFloat;
	var actuating:(String, FastFloat) -> Void;

	inline function new(target:Dynamic, properties:Dynamic, duration:FastFloat = 1.0) {
		this.target = target;
		this.properties = properties;
		this.duration = duration;

		source = Reflect.copy(properties);
		for (prop in Reflect.fields(properties))
			Reflect.setField(source, prop, Reflect.getProperty(target, prop));
		start = Time.time;

		easing = Easing.Linear;
		actuating = (prop, v) -> {
			Reflect.setProperty(target, prop, v);
		};
	}

	public inline function ease(f:(FastFloat) -> FastFloat) {
		easing = f;
	}

	public inline function actuate(f:(String, FastFloat) -> Void) {
		actuating = f;
	}

	public inline function stop() {
		Motion.actuators.remove(this);
	}
}
