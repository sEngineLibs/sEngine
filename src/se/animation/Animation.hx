package se.animation;

import se.Time;
import se.math.VectorMath;
import se.animation.Action.Actuator;

#if !macro
@:build(se.macro.SMacro.build())
#end
@:access(se.animation.Action)
abstract class Animation<T> {
	var actuator:Actuator;

	var _started:Void->Void = () -> {};
	var _stopped:Void->Void = () -> {};
	var _paused:Void->Void = () -> {};
	var _resumed:Void->Void = () -> {};
	var _tick:T->Void;

	var isRunning:Bool = false;
	var isPaused:Bool = false;
	var dTime:Float = 0.0;

	public var from:T;
	public var to:T;
	public var running(get, set):Bool;
	public var paused(get, set):Bool;

	@alias public var duration:Float = actuator.duration;
	@alias public var easing:Float->Float = actuator.easing;

	public function new(from:T, to:T, duration:Float, onTick:T->Void) {
		this.from = from;
		this.to = to;

		_tick = onTick;
		actuator = new Actuator(duration, tick);
	}

	public function start() {
		if (!running) {
			actuator.start = Time.time;
			Action.actuators.push(actuator);
		}
		isRunning = true;
		_started();
		return this;
	}

	public function stop() {
		if (running)
			actuator.stop();
		isRunning = false;
		_stopped();
		return this;
	}

	public function pause() {
		if (running && !paused) {
			actuator.stop();
			dTime = Time.time - actuator.start;
		}
		paused = true;
		_paused();
		return this;
	}

	public function resume() {
		if (running && paused) {
			actuator.start = Time.time - dTime;
			Action.actuators.push(actuator);
		}
		paused = false;
		_resumed();
		return this;
	}

	public function restart() {
		stop();
		start();
		return this;
	}

	public function complete() {
		if (running)
			actuator.complete();
		running = false;
		return this;
	}

	public function ease(f:Float->Float) {
		actuator.ease(f);
		return this;
	}

	public function onStarted(f:Void->Void) {
		_started = f;
		return this;
	}

	public function onStopped(f:Void->Void) {
		_stopped = f;
		return this;
	}

	public function onPaused(f:Void->Void) {
		_paused = f;
		return this;
	}

	public function onResumed(f:Void->Void) {
		_resumed = f;
		return this;
	}

	public function onTick(f:T->Void) {
		_tick = f;
		return this;
	}

	public function onCompleted(f:Void->Void) {
		actuator.onCompleted(f);
		return this;
	}

	function tick(t:Float) {
		_tick(update(t));
	}

	abstract function update(t:Float):T;

	function get_running() {
		return isRunning;
	}

	function set_running(value:Bool) {
		if (!running && value)
			start();
		else if (running && !value)
			stop();
		return value;
	}

	function get_paused() {
		return isPaused;
	}

	function set_paused(value:Bool) {
		if (!paused && value)
			pause();
		else if (paused && !value)
			resume();
		return value;
	}
}
