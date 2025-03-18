package se;

import kha.Assets;
import kha.System;
import se.Time;
import se.input.Mouse;
import se.input.Keyboard;
import s2d.WindowScene;
import s2d.graphics.Drawers;

@:build(se.macro.SMacro.build())
class App {
	@:signal static function update();

	public static var input:{
		var mouse:Mouse;
		var keyboard:Keyboard;
	};
	public static var scenes:Array<WindowScene>;

	public static function start(options:SystemOptions, setup:Void->Void) {
		onUpdate(Time.update);

		System.start(options, function(window) {
			App.input = {
				mouse: new Mouse(),
				keyboard: new Keyboard()
			}

			scenes = [new WindowScene(window)];

			Assets.loadEverything(function() {
				Drawers.compile();
				setup();
				System.notifyOnFrames(function(frames) {
					update();
					for (i in 0...frames.length)
						scenes[i].render(frames[i]);
				});
			});
		});
	}

	public static function stop() {
		if (!System.stop())
			trace("This application can't be stopped!");
	}
}
