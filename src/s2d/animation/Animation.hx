package s2d.animation;

import kha.FastFloat;
import kha.Scheduler;

class Animation {
	var taskID:Int = -1;
	var task:Void->Void;
	var repeat:Bool;
	var running:Bool = false;

	public var tickrate:FastFloat;
	@:isVar public var paused(default, set):Bool = false;

	public inline function new(task:Void->Void, ?tickrate:FastFloat = 60.0) {
		this.task = task;
		this.tickrate = tickrate;
		this.repeat = false;
	}

	public function play(duration:FastFloat) {
		stop();
		this.running = true;
		taskID = Scheduler.addTimeTask(task, 0.0, 1.0 / tickrate, duration);
	}

	public function loop() {
		play(0.0);
	}

	public function stop() {
		if (taskID != -1) {
			Scheduler.removeTimeTask(taskID);
			taskID = -1;
		}
		running = false;
		paused = false;
	}

	public function pause() {
		paused = true;
	}

	public function resume() {
		paused = false;
	}

	public function isStopped():Bool {
		return !running;
	}

	private inline function set_paused(value:Bool):Bool {
		paused = value;
		if (running && taskID != -1)
			Scheduler.pauseTimeTask(taskID, value);
		return value;
	}
}
