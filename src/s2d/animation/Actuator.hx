package s2d.animation;

import kha.FastFloat;
// s2d
import s2d.core.math.MathUtils;

@:allow(s2d.animation.Action)
class Actuator<T> {
	var source:T;
	var target:T;

	var start:FastFloat;
	var duration:FastFloat;
	var easing:(FastFloat) -> FastFloat;

	var onTick:(T) -> Void;
	var onDone:(T) -> Void;

	inline function new(source:T, target:T, ?duration:FastFloat = 1.0) {
		this.source = source;
		this.target = target;
		this.duration = duration;
		easing = Easing.Linear;
		onTick = (v:T) -> {};
		onDone = (v:T) -> {};
	}

	inline function advance(time:FastFloat) {
		final t = (time - start) / duration;
		if (t < 1.0) {
			var v = MathUtils.mix(source, target, easing(t));
			onTick(v);
		} else {
			onDone(target);
			stop();
		}
	}

	public inline function notifyOnTick(f:(T) -> Void) {
		onTick = f;
		return this;
	}

	public inline function notifyOnDone(f:(T) -> Void) {
		onDone = f;
		return this;
	}

	public inline function ease(f:(FastFloat) -> FastFloat) {
		easing = f;
		return this;
	}

	public inline function stop() {
		Action.actuators.remove(this);
	}
}
