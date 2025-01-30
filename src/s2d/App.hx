package s2d;

import kha.Assets;
import kha.System;
import kha.Window;
// s2d
import s2d.core.Time;
import s2d.input.Mouse;
import s2d.input.Keyboard;
import s2d.events.Dispatcher;

class App {
	public static var window:Window;
	public static var input = {
		mouse: Mouse,
		keyboard: Keyboard
	};

	public static function start(options:SystemOptions, setup:Void->Void) {
		System.start(options, function(window) {
			App.window = window;
			App.input.mouse.set();
			App.input.keyboard.set();
			S2D.start(window);
			Assets.loadEverything(function() {
				setup();
				System.notifyOnFrames(function(frames) {
					update();
					S2D.render(frames[0]);
				});
			});
		});
	}

	public static function stop() {
		if (!System.stop())
			trace("This application can't be stopped");
	}

	static function update() {
		Time.update();
		Dispatcher.update();
		S2D.update();
	}
}
