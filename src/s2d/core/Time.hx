package s2d.core;

import kha.System;
import kha.FastFloat;

@:allow(s2d.S2D)
@:build(s2d.core.macro.SMacro.build())
class Time {
	@readonly public static var realTime:FastFloat = 0.0;
	@readonly public static var time:FastFloat = 0.0;
	@readonly public static var delta:FastFloat = 0.0;
	public static var scale:FastFloat = 1.0;

	static var timeListeners:Array<TimeListener> = [];
	static var realTimeListeners:Array<TimeListener> = [];

	/**
	 * Adds a time listener
	 * @param callback A function to call
	 * @param time Timestamp in seconds
	 * @return Returns a listener
	 */
	public static inline function notifyOnTime(callback:Void->Void, time:FastFloat) {
		var listener = {f: callback, time: time};
		timeListeners.push(listener);
		return listener;
	}

	/**
	 * Adds a real time listener
	 * @param callback A function to call
	 * @param time Real timestamp in seconds
	 * @return Returns a listener
	 */
	public static inline function notifyOnRealTime(callback:Void->Void, time:FastFloat) {
		var listener = {f: callback, time: time};
		realTimeListeners.push(listener);
		return listener;
	}

	static inline function update() {
		final rt = System.time;
		delta = (rt - realTime) * scale;
		realTime = rt;
		time += delta;
		for (l in timeListeners) {
			if (time >= l.time) {
				l.f();
				timeListeners.remove(l);
			}
		}
		for (l in realTimeListeners) {
			if (time >= l.time) {
				l.f();
				realTimeListeners.remove(l);
			}
		}
	}
}

typedef TimeListener = {
	f:Void->Void,
	time:FastFloat
}
