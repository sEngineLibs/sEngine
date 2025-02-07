package se.system;

import kha.Assets;
import kha.System;
import kha.Window;
import se.system.Time;
import se.system.input.Mouse;
import se.system.input.Keyboard;
import se.events.Dispatcher;

class App {
	public static var window:Window;
	public static var input:AppInput;

	public static function start(options:SystemOptions, setup:Void->Void) {
		System.start(options, function(window) {
			App.window = window;
			App.input = {
				mouse: new Mouse(),
				keyboard: new Keyboard()
			}

			SEngine.start(window);
			Assets.loadEverything(function() {
				setup();
				System.notifyOnFrames(function(frames) {
					update();
					SEngine.render(frames[0]);
				});
			});
		});
	}

	public static function stop() {
		if (!System.stop())
			trace("This application can't be stopped");
	}

	static function update() @:privateAccess {
		Time.update();
		Dispatcher.update();
		SEngine.update();
	}
}

private typedef AppInput = {
	var mouse:Mouse;
	var keyboard:Keyboard;
}
