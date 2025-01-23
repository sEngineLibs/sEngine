package s2d.core;

import s2d.core.Time.TimeListener;

@:access(s2d.core.Time)
class Timer {
	var listener:TimeListener;

	var callback:Void->Void;
	var delay:Float;

	public var started:Bool = false;

	/**
	 * Creates a timer and immediately starts it
	 * @param callback A function to call after the timer was triggered
	 * @param delay Amount of seconds to wait
	 * @return Returns the timer instance
	 */
	public static function set(callback:Void->Void, delay:Float):Timer {
		final timer = new Timer(callback, delay);
		timer.start();
		return timer;
	}

	/**
	 * Creates a timer
	 * @param callback A function to call after the timer was triggered
	 * @param delay Amount of seconds to wait
	 */
	public function new(callback:Void->Void, delay:Float) {
		this.callback = callback;
		this.delay = delay;
	}

	/**
	 * Starts the timer
	 * @param lock Whether to skip if the timer is already started
	 * @return Returns true if the timer was started
	 */
	public function start(?lock:Bool = true):Bool {
		if (!lock || !started) {
			started = true;
			listener = Time.notifyOnTime(() -> {
				callback();
				started = false;
			}, Time.time + delay);
			return true;
		}
		return false;
	}

	/**
	 * Stops the timer
	 */
	public function stop() {
		Time.timeListeners.remove(listener);
	}

	/**
	 * Starts the timer repeatedly.
	 * @param count How many times to start the timer
	 * @param lock Whether to skip if the timer is already started
	 * @return Returns true if the timer was started
	 */
	public function repeat(count:Int = 1, ?lock:Bool = true):Bool {
		if (count <= 0)
			return false;

		if (!lock || !started) {
			started = true;
			final f = callback;
			callback = function() {
				f();
				count--;
				if (count > 0) {
					listener = Time.notifyOnTime(callback, Time.time + delay);
				} else {
					started = false;
					callback = f;
				}
			};
			listener = Time.notifyOnTime(callback, Time.time + delay);
			return true;
		}
		return false;
	}
}
