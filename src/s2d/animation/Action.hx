package s2d.animation;

// s2d
import s2d.core.Time;

@:allow(s2d.S2D)
@:allow(s2d.animation.Actuator)
class Action {
	static var actuators:Array<Actuator> = [];

	public static inline function tween(target:Dynamic, properties:Dynamic, duration:Float):Actuator {
		final actuator = new Actuator(target, properties, duration);
		actuator.start = Time.time;
		actuators.push(actuator);
		return actuator;
	}

	static inline function update(time:Float) {
		for (a in actuators) {
			for (prop in Reflect.fields(a.properties)) {
				final t = (time - a.start) / a.duration;
				final e = Reflect.getProperty(a.properties, prop);
				if (t < 1.0) {
					final s = Reflect.getProperty(a.source, prop);
					final v = lerp(s, e, a.easing(t));
					Reflect.setProperty(a.target, prop, v);
				} else {
					Reflect.setProperty(a.target, prop, e);
					a.stop();
				}
			}
		}
	}

	static inline function lerp(x:Dynamic, y:Dynamic, t:Float):Dynamic {
		return x + (y - x) * t;
	}
}

@:allow(s2d.animation.Action)
private class Actuator {
	var source:Dynamic;
	var target:Dynamic;
	var properties:Dynamic;

	var start:Float;
	var duration:Float;
	var easing:(Float) -> Float;

	inline function new(target:Dynamic, properties:Dynamic, ?duration:Float = 1.0) {
		source = {};
		for (prop in Reflect.fields(properties))
			Reflect.setProperty(source, prop, Reflect.getProperty(target, prop));

		this.target = target;
		this.properties = properties;
		this.duration = duration;
		easing = Easing.Linear;
	}

	public inline function ease(f:(Float) -> Float) {
		easing = f;
		return this;
	}

	public inline function stop() {
		Action.actuators.remove(this);
	}
}
