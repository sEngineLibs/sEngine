package se.animation;

import se.system.Time;
import se.animation.Action.Actuator;

@:access(se.animation.Action)
abstract class Animation<T> {
	var actuator:Actuator;

	var _start:Void->Void = () -> {};
	var _stop:Void->Void = () -> {};
	var _pause:Void->Void = () -> {};
	var _resume:Void->Void = () -> {};
	var _tick:T->Void;
	var _completed:Void->Void;

	var _running:Bool = false;
	var _paused:Bool = false;
	var dTime:Float = 0.0;

	public var from:T;
	public var to:T;
	public var running(get, set):Bool;
	public var paused(get, set):Bool;

	public var duration(get, set):Float;
	public var easing(get, set):Float->Float;

	public function new(from:T, to:T, duration:Float, onTick:T->Void) {
		this.from = from;
		this.to = to;
		this._tick = onTick;
		this.actuator = @:privateAccess new Actuator(duration, tick);
	}

	public function onStart(f:Void->Void) {
		_start = f;
	}

	public function onStop(f:Void->Void) {
		_stop = f;
	}

	public function onPause(f:Void->Void) {
		_pause = f;
	}

	public function onResume(f:Void->Void) {
		_resume = f;
	}

	public function onTick(f:T->Void) {
		_tick = f;
	}

	public function onCompleted(f:Void->Void) {
		_completed = f;
	}

	public function ease(f:Float->Float) {
		actuator.ease(f);
	}

	public function start() {
		if (!running) {
			@:privateAccess actuator.start = Time.time;
			Action.actuators.push(actuator);
			running = true;
			_start();
		}
	}

	public function stop() {
		if (running) {
			actuator.stop();
			running = false;
			_stop();
		}
	}

	public function pause() {
		if (running && !paused) {
			actuator.stop();
			dTime = Time.time - @:privateAccess actuator.start;
			paused = true;
			_pause();
		}
	}

	public function resume() {
		if (running && paused) {
			@:privateAccess actuator.start = Time.time - dTime;
			Action.actuators.push(actuator);
			paused = false;
			_resume();
		}
	}

	public function restart() {
		stop();
		start();
	}

	public function complete() {
		if (running) {
			tick(1.0);
			actuator.stop();
			running = false;
			_completed();
		}
	}

	abstract function update(t:Float):T;

	function tick(t:Float) {
		_tick(update(t));
	}

	function get_duration() {
		return @:privateAccess actuator.duration;
	}

	function set_duration(value:Float) {
		@:privateAccess actuator.duration = value;
		return value;
	}

	function get_easing() {
		return @:privateAccess actuator.easing;
	}

	function set_easing(value:Float->Float) {
		ease(value);
		return value;
	}

	function get_running() {
		return _running;
	}

	function set_running(value:Bool) {
		if (!running && value)
			start();
		else
			stop();
		return value;
	}

	function get_paused() {
		return _paused;
	}

	function set_paused(value:Bool) {
		if (!paused && value)
			pause();
		else
			resume();
		return value;
	}
}
