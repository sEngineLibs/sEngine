package se;

import kha.Framebuffer;
import kha.Assets;
import kha.System;
import se.Time;
import se.input.Mouse;
import se.input.Keyboard;
import se.animation.Action;
import s2d.WindowScene;
import s2d.graphics.Drawers;

@:build(se.macro.SMacro.build())
class App {
	@:signal static function update();

	public static var input(default, null):{
		var mouse:Mouse;
		var keyboard:Keyboard;
	};
	public static var scenes(default, null):Array<WindowScene>;

	public static function start(options:SystemOptions, setup:Void->Void) {
		onUpdate(() -> @:privateAccess {
			Time.update();
			Action.update(Time.time);
		});

		System.start(options, window -> {
			App.input = {
				mouse: new Mouse(),
				keyboard: new Keyboard()
			}
			scenes = [new WindowScene(window)];
			Assets.loadEverything(() -> {
				Drawers.compile();
				setup();
				System.notifyOnFrames(frames -> {
					update();
					for (i in 0...frames.length)
						scenes[i].render(frames[i]);
				});
			});
		});
	}

	public static function stop() {
		if (!System.stop())
			Log.error("This application can't be stopped!");
	}
}
