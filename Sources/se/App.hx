package se;

import kha.Assets;
import kha.System;
import kha.Window;
import se.system.Time;
import se.system.input.Mouse;
import se.system.input.Keyboard;

@:build(se.macro.SMacro.build())
class App {
	@:signal static function update();

	public static var windows(get, never):Array<Window>;
	public static var input:{
		var mouse:Mouse;
		var keyboard:Keyboard;
	};

	public static function start(options:SystemOptions, setup:Void->Void) {
		onUpdate(Time.update);

		System.start(options, function(window) {
			App.input = {
				mouse: new Mouse(),
				keyboard: new Keyboard()
			}
			SEngine.start(window);
			Assets.loadEverything(function() {
				setup();

				System.notifyOnFrames(function(frames) {
					update();

					var frame = SEngine.render();

					final g2 = frames[0].g2;
					g2.begin();
					g2.drawImage(frame, 0, 0);
					g2.end();
				});
			});
		});
	}

	public static function stop() {
		if (!System.stop())
			trace("This application can't be stopped!");
	}

	static private inline function get_windows() {
		return Window.all;
	}
}
