package s2d.animation;

// s2d
import s2d.core.Time;

@:allow(s2d.S2D)
@:allow(s2d.animation.Actuator)
class Action {
	static var actuators:Array<Actuator> = [];

	public static inline function tween(duration:Float = 1.0, onTick:(Float) -> Void):Actuator {
		final actuator = new Actuator(duration, onTick);
		actuator.start = Time.time;
		actuators.push(actuator);
		return actuator;
	}

	static inline function update(time:Float) {
		for (a in actuators) {
			final t = (time - a.start) / a.duration;
			if (t < 1.0) {
				a.tick(a.easing(t));
			} else {
				a.done();
				actuators.remove(a);
			}
		}
	}
}

@:allow(s2d.animation.Action)
private class Actuator {
	var start:Float;
	var duration:Float;
	var easing:Float->Float;
	var tick:Float->Void;
	var done:Void->Void = () -> {};

	inline function new(duration:Float = 1.0, onTick:Float->Void) {
		this.duration = duration;
		this.tick = onTick;
		easing = Easing.Linear;
	}

	public inline function ease(f:Float->Float) {
		easing = f;
		return this;
	}

	public inline function onTick(f:Float->Void) {
		tick = f;
		return this;
	}

	public inline function onDone(f:Void->Float) {
		done = f;
		return this;
	}

	public inline function stop() {
		Action.actuators.remove(this);
	}
}
