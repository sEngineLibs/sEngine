package se;

import kha.System;
import kha.Framebuffer;
import aura.Aura;
import se.input.Mouse;
import se.input.Keyboard;
import se.animation.Action;
import s2d.graphics.Drawers;

@:build(se.macro.SMacro.build())
class App {
	@:signal static function update();

	public static var input(default, null):{
		var mouse:Mouse;
		var keyboard:Keyboard;
	};
	public static var windows(default, null):Array<Window>;

	public static function start(options:SystemOptions, setup:Window->Void) {
		onUpdate(() -> @:privateAccess {
			Time.update();
			Action.update(Time.time);
		});
		var loaded = true;
		Resource.loadShelf({
			fonts: ["font_default"],
			images: ["image_default"]
		}, _ -> {
			if (loaded)
				System.start(options, window -> {
					Aura.init();
					Drawers.compile();

					App.input = {
						mouse: new Mouse(),
						keyboard: new Keyboard()
					}

					var w = new Window(window);
					windows = [w];
					setup(w);

					System.notifyOnFrames(frames -> {
						update();
						render(frames);
					});
				});
			else
				App.exit();
		}, progress -> {
			Log.debug('Loading starter assets: ${Std.int(progress * 100)}%');
		}, err -> {
			Log.error('Failed to load starter asset ${err.source}: ${err.message}');
			loaded = false;
		});
	}

	public static function exit() {
		if (!System.stop())
			Log.error("This application can't be stopped!");
	}

	static inline function render(frames:Array<Framebuffer>) @:privateAccess {
		for (i in 0...frames.length)
			windows[i].render(frames[i]);
	}
}
