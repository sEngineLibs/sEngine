package se.animation;

import se.system.Time;

/**
	This class manages tween animations, allowing smooth transitions over time.

	@see `Actuator`
 */
@:allow(se.SEngine)
class Action {
	static var actuators:Array<Actuator> = [];

	/**
		Creates a tween animation.

		@param duration The duration of the tween in seconds.
		@param onTick A callback function that is called every frame with a progress value (0 to 1).
		@return The created Actuator instance.
	 */
	public static function tween(duration:Float = 1.0, onTick:(Float) -> Void):Actuator {
		final actuator = new Actuator(duration, onTick);
		actuator.start = Time.time;
		actuators.push(actuator);
		return actuator;
	}

	static function update(time:Float) {
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

/**
	This class represents an individual animation actuator.

	It handles easing functions, animation updates, and completion callbacks.

	@see `Action`
 */
@:allow(se.animation.Action)
@:access(se.animation.Action)
class Actuator {
	var start:Float;
	var duration:Float;
	var easing:Float->Float;
	var tick:Float->Void;
	var done:Void->Void = () -> {};

	function new(duration:Float = 1.0, onTick:Float->Void) {
		this.duration = duration;
		this.tick = onTick;
		easing = Easing.Linear;
	}

	/**
		Sets the easing function for the animation.

		@param f The easing function to use.
	 */
	public function ease(f:Float->Float):Actuator {
		easing = f;
		return this;
	}

	/**
		Sets a new tick callback function.

		@param f The function to call on each animation update.
	 */
	public function onTick(f:Float->Void):Actuator {
		tick = f;
		return this;
	}

	/**
		Sets a callback function to execute when the animation is complete.

		@param f The function to call when done.
	 */
	public function onDone(f:Void->Void):Actuator {
		done = f;
		return this;
	}

	/**
		Stops the animation and removes it from the active actuators list.
	 */
	public function stop() {
		Action.actuators.remove(this);
	}
}
